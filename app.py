# app.py
from flask import Flask, render_template, request, redirect, session, url_for, flash
from flask_mysqldb import MySQL
import MySQLdb.cursors
import pandas as pd
from datetime import datetime

app = Flask(__name__)
app.secret_key = 'replace_with_a_random_secret'

# ---------- MySQL config - UPDATE your password if needed ----------
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'Root@123'   # <-- change this
app.config['MYSQL_DB'] = 'internship_portal'
mysql = MySQL(app)

# ---------- Home ----------
@app.route('/')
def index():
    return render_template('index.html')

# ---------- Student login ----------
@app.route('/student_login', methods=['GET','POST'])
def student_login():
    if request.method == 'POST':
        prn = request.form['prn'].strip()
        password = request.form['password'].strip()
        cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cur.execute("SELECT * FROM students WHERE PRN=%s AND Password=%s", (prn, password))
        student = cur.fetchone()
        cur.close()
        if student:
            session['student_prn'] = student['PRN']
            session['student_name'] = student['Name']
            return redirect(url_for('student_dashboard'))
        else:
            flash('Invalid PRN or password', 'danger')
    return render_template('student_login.html')

# ---------- Student dashboard (eligible internships + recommendation) ----------
@app.route('/student_dashboard')
def student_dashboard():
    if 'student_prn' not in session:
        return redirect(url_for('student_login'))

    prn = session['student_prn']
    cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cur.execute("SELECT * FROM students WHERE PRN=%s", (prn,))
    student = cur.fetchone()

    # fetch internships that match student's dept and min cgpa <= student.cgpa
    cur.execute("""
        SELECT i.InternshipID, i.Domain, i.MinCGPA, i.Department, i.CompanyID, i.Description,
               c.Name as CompanyName
        FROM internships i
        JOIN companies c ON i.CompanyID = c.CompanyID
        WHERE (i.Department = %s OR i.Department = 'All') AND i.MinCGPA <= %s
        """, (student['Department'], student['CGPA']))
    internships = cur.fetchall()

    # Simple recommend: score by domain match and closeness of CGPA to MinCGPA
    df = pd.DataFrame(internships)
    recommended = []
    if not df.empty:
        df['domain_match'] = df['Domain'].apply(lambda d: 1 if d == student['DomainPreference'] else 0)
        df['cgpa_diff'] = (student['CGPA'] - df['MinCGPA']).abs()
        # score: domain_match (weight 0.6), smaller cgpa_diff better (weight 0.4)
        df['score'] = df['domain_match'] * 0.6 + (1 / (1 + df['cgpa_diff'])) * 0.4
        df_sorted = df.sort_values('score', ascending=False).head(5)
        recommended = df_sorted.to_dict(orient='records')

    # check which internships the student already applied to (to disable Apply button)
    cur.execute("SELECT InternshipID FROM applications WHERE PRN=%s", (prn,))
    applied_rows = cur.fetchall()
    applied_ids = {r['InternshipID'] for r in applied_rows}

    # Fetch applications for this student
    cur.execute("""SELECT a.ApplicationID, a.InternshipID, a.Status, i.Domain, c.Name AS CompanyName, a.AppliedOn
        FROM applications a
        JOIN internships i ON a.InternshipID = i.InternshipID
        JOIN companies c ON i.CompanyID = c.CompanyID
        WHERE a.PRN = %s
        ORDER BY a.AppliedOn DESC""", (prn,))
    student_applications = cur.fetchall()


    cur.close()
    return render_template('student_dashboard.html', student=student,
                            internships=internships, recommended=recommended,
                            applied_ids=applied_ids, applications=student_applications)

# ---------- Apply for internship ----------
@app.route('/apply', methods=['POST'])
def apply():
    if 'student_prn' not in session:
        return redirect(url_for('student_login'))
    internship_id = request.form.get('internship_id')
    prn = session['student_prn']
    cur = mysql.connection.cursor()
    # prevent duplicate
    cur.execute("SELECT * FROM applications WHERE PRN=%s AND InternshipID=%s", (prn, internship_id))
    if cur.fetchone():
        flash('You have already applied for this internship.', 'info')
    else:
        cur.execute("INSERT INTO applications (PRN, InternshipID, Status, AppliedOn) VALUES (%s, %s, %s, %s)",
                    (prn, internship_id, 'Pending', datetime.now().date()))
        mysql.connection.commit()
        flash('Application submitted successfully.', 'success')
    cur.close()
    return redirect(url_for('student_dashboard'))

# ---------- Faculty login ----------
@app.route('/faculty_login', methods=['GET','POST'])
def faculty_login():
    if request.method == 'POST':
        email = request.form['email'].strip()
        password = request.form['password'].strip()
        cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cur.execute("SELECT * FROM faculty WHERE Email=%s AND Password=%s", (email, password))
        faculty = cur.fetchone()
        cur.close()
        if faculty:
            session['faculty_id'] = faculty['FacultyID']
            session['faculty_name'] = faculty['Name']
            return redirect(url_for('faculty_dashboard'))
        else:
            flash('Invalid faculty credentials', 'danger')
    return render_template('faculty_login.html')

# ---------- Faculty dashboard: add internship + view applications ----------
@app.route('/faculty_dashboard', methods=['GET', 'POST'])
def faculty_dashboard():
    if 'faculty_id' not in session:
        return redirect(url_for('faculty_login'))

    cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    if request.method == 'POST':
        # Add new internship posted by this faculty
        domain = request.form['domain'].strip()
        mincgpa = float(request.form['mincgpa'])
        department = request.form['department'].strip()
        companyid = int(request.form['companyid'])
        desc = request.form['description'].strip()
        facid = session['faculty_id']
        cur.execute("""INSERT INTO internships (Domain, MinCGPA, Department, CompanyID, FacultyID, Description)
                       VALUES (%s,%s,%s,%s,%s,%s)""", (domain, mincgpa, department, companyid, facid, desc))
        mysql.connection.commit()
        flash('Internship posted.', 'success')

    # Load internships and applications
    cur.execute("""SELECT i.InternshipID, i.Domain, i.MinCGPA, i.Department, c.Name as CompanyName, f.Name as FacultyName
                   FROM internships i
                   LEFT JOIN companies c ON i.CompanyID = c.CompanyID
                   LEFT JOIN faculty f ON i.FacultyID = f.FacultyID
                   ORDER BY i.InternshipID DESC""")
    internships = cur.fetchall()

    cur.execute("""SELECT a.ApplicationID, a.PRN, s.Name as StudentName, i.InternshipID, i.Domain, c.Name as CompanyName, a.Status, a.AppliedOn
                   FROM applications a
                   JOIN students s ON a.PRN = s.PRN
                   JOIN internships i ON a.InternshipID = i.InternshipID
                   JOIN companies c ON i.CompanyID = c.CompanyID
                   ORDER BY a.AppliedOn DESC""")
    applications = cur.fetchall()
    cur.close()
    return render_template('faculty_dashboard.html', internships=internships, applications=applications)

# ---------- Logout ----------
@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('index'))

    # ---------- Update Application Status ----------
@app.route('/update_status', methods=['POST'])
def update_status():
    if 'faculty_id' not in session:
        return redirect(url_for('faculty_login'))

    appid = request.form['appid']
    status = request.form['status']

    cur = mysql.connection.cursor()
    cur.execute("UPDATE applications SET Status=%s WHERE ApplicationID=%s", (status, appid))
    mysql.connection.commit()
    cur.close()

    flash(f'Application {appid} marked as {status}.', 'success')
    return redirect(url_for('faculty_dashboard'))


if __name__ == '__main__':
    app.run(debug=True)
