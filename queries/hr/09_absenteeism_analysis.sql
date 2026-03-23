-- =============================================
-- Query: Absenteeism Analysis
-- Category: HR Analytics
-- Difficulty: Intermediate
--
-- Business Question:
-- What are our absenteeism patterns? Which departments or
-- employees have attendance issues? What's the cost impact?
--
-- Use Case:
-- Workforce management, policy compliance monitoring,
-- and identifying potential employee engagement issues.
-- =============================================

-- Overall attendance summary
SELECT
    COUNT(*) AS total_records,
    COUNT(CASE WHEN status = 'Present' THEN 1 END) AS present_days,
    COUNT(CASE WHEN status = 'Absent' THEN 1 END) AS absent_days,
    COUNT(CASE WHEN status = 'Late' THEN 1 END) AS late_days,
    COUNT(CASE WHEN status = 'On Leave' THEN 1 END) AS leave_days,
    ROUND(COUNT(CASE WHEN status = 'Absent' THEN 1 END) * 100.0 / COUNT(*), 2) AS absence_rate,
    ROUND(COUNT(CASE WHEN status = 'Late' THEN 1 END) * 100.0 / COUNT(*), 2) AS late_rate
FROM attendance;

-- =============================================
-- Expected Output:
-- | total_records | present_days | absent_days | late_days | absence_rate | late_rate |
-- |---------------|--------------|-------------|-----------|--------------|-----------|
-- | 20            | 14           | 1           | 3         | 5.00         | 15.00     |
-- =============================================

-- Attendance by employee
SELECT
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    e.department,
    COUNT(a.attendance_id) AS total_days,
    COUNT(CASE WHEN a.status = 'Present' THEN 1 END) AS present,
    COUNT(CASE WHEN a.status = 'Absent' THEN 1 END) AS absent,
    COUNT(CASE WHEN a.status = 'Late' THEN 1 END) AS late,
    ROUND(COUNT(CASE WHEN a.status = 'Present' THEN 1 END) * 100.0 / COUNT(a.attendance_id), 2) AS attendance_rate,
    ROUND(SUM(a.hours_worked), 1) AS total_hours,
    ROUND(SUM(a.overtime_hours), 1) AS total_overtime
FROM employees e
LEFT JOIN attendance a ON e.employee_id = a.employee_id
WHERE e.status = 'Active'
GROUP BY e.employee_id, employee_name, e.department
HAVING total_days > 0
ORDER BY attendance_rate ASC;

-- Attendance by department
SELECT
    e.department,
    COUNT(DISTINCT e.employee_id) AS employees,
    COUNT(a.attendance_id) AS total_records,
    COUNT(CASE WHEN a.status = 'Present' THEN 1 END) AS present,
    COUNT(CASE WHEN a.status = 'Absent' THEN 1 END) AS absent,
    COUNT(CASE WHEN a.status = 'Late' THEN 1 END) AS late,
    ROUND(COUNT(CASE WHEN a.status = 'Absent' THEN 1 END) * 100.0 / COUNT(a.attendance_id), 2) AS absence_rate,
    ROUND(AVG(a.hours_worked), 2) AS avg_hours_per_day
FROM employees e
INNER JOIN attendance a ON e.employee_id = a.employee_id
WHERE e.status = 'Active'
GROUP BY e.department
ORDER BY absence_rate DESC;

-- Day of week absenteeism pattern
SELECT
    CASE CAST(strftime('%w', attendance_date) AS INTEGER)
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END AS day_name,
    COUNT(*) AS total_records,
    COUNT(CASE WHEN status = 'Absent' THEN 1 END) AS absences,
    COUNT(CASE WHEN status = 'Late' THEN 1 END) AS late_arrivals,
    ROUND(COUNT(CASE WHEN status = 'Absent' THEN 1 END) * 100.0 / COUNT(*), 2) AS absence_rate
FROM attendance
GROUP BY CAST(strftime('%w', attendance_date) AS INTEGER), day_name
ORDER BY CAST(strftime('%w', attendance_date) AS INTEGER);

-- Cost of absenteeism (estimated)
WITH absence_cost AS (
    SELECT
        e.department,
        COUNT(CASE WHEN a.status = 'Absent' THEN 1 END) AS absent_days,
        AVG(e.salary) AS avg_daily_salary
    FROM employees e
    INNER JOIN attendance a ON e.employee_id = a.employee_id
    WHERE e.status = 'Active'
    GROUP BY e.department
)
SELECT
    department,
    absent_days,
    ROUND(avg_daily_salary / 22, 2) AS daily_rate,
    ROUND(absent_days * (avg_daily_salary / 22), 2) AS estimated_absence_cost
FROM absence_cost
ORDER BY estimated_absence_cost DESC;

-- Employees with attendance issues (high absence or lateness)
SELECT
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    e.department,
    e.job_title,
    COUNT(CASE WHEN a.status = 'Absent' THEN 1 END) AS absence_count,
    COUNT(CASE WHEN a.status = 'Late' THEN 1 END) AS late_count,
    ROUND(COUNT(CASE WHEN a.status IN ('Absent', 'Late') THEN 1 END) * 100.0 / COUNT(*), 2) AS issue_rate,
    CASE
        WHEN COUNT(CASE WHEN a.status = 'Absent' THEN 1 END) >= 3 THEN 'High Absence'
        WHEN COUNT(CASE WHEN a.status = 'Late' THEN 1 END) >= 3 THEN 'Frequent Lateness'
        ELSE 'Monitor'
    END AS attention_flag
FROM employees e
INNER JOIN attendance a ON e.employee_id = a.employee_id
WHERE e.status = 'Active'
GROUP BY e.employee_id, employee_name, e.department, e.job_title
HAVING absence_count > 0 OR late_count > 1
ORDER BY issue_rate DESC;

-- Overtime analysis
SELECT
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    e.department,
    SUM(a.overtime_hours) AS total_overtime_hours,
    COUNT(CASE WHEN a.overtime_hours > 0 THEN 1 END) AS overtime_days,
    ROUND(AVG(CASE WHEN a.overtime_hours > 0 THEN a.overtime_hours END), 2) AS avg_overtime_per_day,
    ROUND(SUM(a.overtime_hours) * (e.salary / 22 / 8) * 1.5, 2) AS estimated_overtime_cost
FROM employees e
INNER JOIN attendance a ON e.employee_id = a.employee_id
WHERE e.status = 'Active'
GROUP BY e.employee_id, employee_name, e.department, e.salary
HAVING total_overtime_hours > 0
ORDER BY total_overtime_hours DESC;
