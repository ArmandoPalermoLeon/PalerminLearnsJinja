from flask import render_template
from helpers import execute_query


def index():
    # --- Stats for the hero bar and about section ---
    students_result = execute_query("SELECT COUNT(*) AS total FROM students", [])
    courses_result  = execute_query("SELECT COUNT(*) AS total FROM courses", [])
    profs_result    = execute_query("SELECT COUNT(*) AS total FROM professors", [])
    depts_result    = execute_query("SELECT COUNT(*) AS total FROM department", [])

    stats = {
        'students':    students_result[0]['total']    if students_result    else 0,
        'courses':     courses_result[0]['total']     if courses_result     else 0,
        'professors':  profs_result[0]['total']       if profs_result       else 0,
        'departments': depts_result[0]['total']       if depts_result       else 0,
    }

    # --- Featured degrees (all, ordered by level) ---
    degrees = execute_query(
        "SELECT id_degree, level, duration, description FROM degrees ORDER BY level",
        []
    )

    return render_template('landing.html', stats=stats, degrees=degrees)
