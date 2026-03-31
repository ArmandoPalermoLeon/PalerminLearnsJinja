CREATE DATABASE university;
-- Enum types 
CREATE TYPE employee_status AS ENUM ('Active', 'Inactive', 'Not working');
CREATE TYPE enrollment_status as ENUM('Enrolled', 'Withdrawn', 'Completed','Failed');
CREATE TYPE manager_op_status AS ENUM ('Active','On Leave','Terminated');
CREATE TYPE user_role AS ENUM ('Admin','Student','Professor','Staff');
CREATE TYPE account_status AS ENUM ('Active','Suspended','Inactive');
CREATE TYPE student_bill_status as ENUM ('Pending','Paid','Overdue','Cancelled');
CREATE TYPE payment_method AS ENUM ('Cash','Credit Card','Bank Transfer','Scholarship');
CREATE TYPE sport_season AS ENUM ('Fall', 'Spring', 'Summer', 'Year-Round');
CREATE TYPE room_assignment_type as ENUM ('Assigned','Pending','Vacated');
--
-- Let's divide it in indiviual tables (those who doesnt need a primary key)
CREATE TABLE courses(
  id_course INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  credits INT NOT NULL CHECK (credits > 0),
  CODE varchar(50) NOT NULL UNIQUE,
  title varchar(100) NOT NULL,
  description TEXT NOT NULL
);

CREATE TABLE SEMESTERS(
  id_semester INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name varchar(50) NOT NULL UNIQUE,
  start_date DATE NOT NULL,
  end_date  DATE NOT NULL,
  CONSTRAINT chk_semester_dates CHECK (end_date > start_date)
);

CREATE TABLE degrees(
  id_degree INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name_degree varchar(100) not null,
  duration varchar(50) NOT NULL,
  level varchar(50) NOT NULL,
  description TEXT NOT NULL
);


CREATE TABLE employee_type(
  id_employee_type INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name_type varchar(50) NOT NULL UNIQUE
);

CREATE TABLE buildings(
  id_building INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  title varchar(100) NOT NULL,
  capacity INT NOT NULL CHECK (capacity > 0),
  code varchar(12) NOT NULL UNIQUE,
  address varchar(100) NOT NULL,
  year_built DATE NOT NULL,
  architect varchar(100)
);

CREATE TABLE type_scholarship(
  id_type_scholarship INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  type_name varchar(100) not null UNIQUE
);

CREATE TABLE sports(
  id_sport INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name varchar(100) NOT NULL UNIQUE,
  season sport_season NOT NULL
);

CREATE TABLE food_catalog(
  id_foods INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name varchar(100) NOT NULL,
  description TEXT,
  ingredients TEXT,
  cooking_recipe TEXT
);

CREATE TABLE department(
  id_department INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name_department VARCHAR(100) NOT NULL UNIQUE
);

-- Dependent 
CREATE TABLE students(
  id_student INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  first_name varchar(100) NOT NULL,
  last_name varchar(100) NOT NULL,
  birth_date DATE NOT NULL,
  email TEXT NOT NULL UNIQUE,
  phone varchar(20),
  start_date DATE,
  fk_id_degree INT NOT NULL,
  CONSTRAINT fk_student_degree FOREIGN KEY (fk_id_degree) REFERENCES degrees(id_degree)
);

CREATE TABLE employees(
  id_employee INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  first_name varchar(50) NOT NULL,
  last_name varchar(50) NOT NULL,
  email TEXT NOT NULL UNIQUE,
  phone varchar(20) NOT NULL,
  start_date DATE NOT NULL,
  birth_date DATE NOT NULL,
  status employee_status DEFAULT 'Active',
  SALARY DECIMAL(10,2) NOT NULL CHECK (salary >= 0),
  fk_id_department INT,
  fk_id_employee_type INT NOT NULL,
  CONSTRAINT fk_emp_type FOREIGN KEY (fk_id_employee_type) REFERENCES employee_type(id_employee_type),
  CONSTRAINT fk_emp_department FOREIGN KEY (fk_id_department) REFERENCES department(id_department)
);

CREATE TABLE professors(
  id_professor INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  fk_id_department INT NOT NULL,
  fk_id_employee INT NOT NULL UNIQUE,
  CONSTRAINT fk_prof_dept FOREIGN KEY (fk_id_department) REFERENCES department(id_department),
  CONSTRAINT fk_prof_employee FOREIGN KEY (fk_id_employee) REFERENCES employees(id_employee)
);

CREATE TABLE classrooms(
  id_classroom INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  fk_id_building INT NOT NULL,
  number varchar(20) NOT NULL,
  capacity INT NOT NULL CHECK (capacity > 0),
  has_computers BOOLEAN NOT NULL DEFAULT FALSE,
  has_whiteboard BOOLEAN NOT NULL DEFAULT TRUE,
  CONSTRAINT fk_classroom_building FOREIGN KEY (fk_id_building) REFERENCES buildings(id_building),
  CONSTRAINT uq_classroom UNIQUE (fk_id_building, number)
);

CREATE TABLE computers(
  id_computer INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  fk_id_department INT,
  fk_id_classroom INT NOT NULL,
  is_operational BOOLEAN NOT NULL DEFAULT TRUE,
  CONSTRAINT fk_computer_dept FOREIGN KEY (fk_id_department) REFERENCES department(id_department),
  CONSTRAINT fk_computer_classroom FOREIGN KEY (fk_id_classroom) REFERENCES classrooms(id_classroom)
);

CREATE TABLE course_selection(
  id_course_selection INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  fk_id_course INT NOT NULL,
  fk_semester INT NOT NULL,
  fk_classroom INT NOT NULL,
  fk_id_professor INT NOT NULL,
  CONSTRAINT fk_cs_course FOREIGN KEY (fk_id_course) REFERENCES courses(id_course),
  CONSTRAINT fk_cs_semester FOREIGN KEY (fk_semester) REFERENCES semesters(id_semester),
  CONSTRAINT fk_cs_classroom FOREIGN KEY (fk_classroom) REFERENCES classrooms(id_classroom),
  CONSTRAINT fk_cs_professor FOREIGN KEY (fk_id_professor) REFERENCES professors(id_professor)
);

CREATE TABLE student_enrollments(
  id_student_enrollment INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  fk_id_course_selection INT NOT NULL,
  enrollment_date DATE NOT NULL DEFAULT CURRENT_DATE,
  fk_id_student INT NOT NULL,
  status enrollment_status NOT NULL DEFAULT 'Enrolled',
  CONSTRAINT fk_enroll_course_sel FOREIGN KEY (fk_id_course_selection) REFERENCES course_selection(id_course_selection),
  CONSTRAINT fk_enroll_student FOREIGN KEY (fk_id_student) REFERENCES students(id_student),
  CONSTRAINT uq_enrollment UNIQUE (fk_id_course_selection, fk_id_student)
);

CREATE TABLE grades(
  id_grade INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  fk_id_student_enrollment INT NOT NULL,
  assignment_name VARCHAR(200) NOT NULL,
  score DECIMAL(5,2) NOT NULL CHECK (score >= 0 AND score <= 100),
  CONSTRAINT fk_grade_enrollment FOREIGN KEY (fk_id_student_enrollment) REFERENCES student_enrollments(id_student_enrollment)
);

CREATE TABLE courses_degree(
  id_courses_degree INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  fk_id_course INT NOT NULL,
  fk_id_degree INT NOT NULL,
  CONSTRAINT fk_cd_course FOREIGN KEY (fk_id_course) REFERENCES courses(id_course),
  CONSTRAINT fk_cd_degree FOREIGN KEY (fk_id_degree) REFERENCES degrees(id_degree),
  CONSTRAINT uq_courses_degree UNIQUE (fk_id_course, fk_id_degree)
);

CREATE TABLE degree_curriculum(
  id_degree_curriculum INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  fk_id_degree INT NOT NULL,
  fk_id_course INT NOT NULL,
  semester_year INT NOT NULL CHECK (semester_year > 0),
  is_required BOOLEAN NOT NULL DEFAULT TRUE,
  notes TEXT,
  CONSTRAINT fk_dc_degree FOREIGN KEY (fk_id_degree) REFERENCES degrees(id_degree),
  CONSTRAINT fk_dc_course FOREIGN KEY (fk_id_course) REFERENCES courses(id_course),
  CONSTRAINT uq_degree_curriculum UNIQUE (fk_id_degree, fk_id_course)
);

CREATE TABLE degree_department(
  id_degree_department INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  fk_id_department INT NOT NULL,
  fk_id_degree INT NOT NULL,
  CONSTRAINT fk_dd_dept FOREIGN KEY (fk_id_department) REFERENCES department(id_department),
  CONSTRAINT fk_dd_degree FOREIGN KEY (fk_id_degree) REFERENCES degrees(id_degree),
  CONSTRAINT uq_degree_department UNIQUE (fk_id_department, fk_id_degree)
);

CREATE TABLE managers(
  id_manager INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  fk_id_building INT NOT NULL,
  start_date DATE NOT NULL,
  operational_status manager_op_status NOT NULL DEFAULT 'Active',
  fk_id_employee INT NOT NULL UNIQUE,
  CONSTRAINT fk_mgr_building FOREIGN KEY (fk_id_building) REFERENCES buildings(id_building),
  CONSTRAINT fk_mgr_employee FOREIGN KEY (fk_id_employee) REFERENCES employees(id_employee)
);

CREATE TABLE services(
  id_services INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name_service VARCHAR(100) NOT NULL,
  fk_id_building INT NOT NULL,
  CONSTRAINT fk_svc_building FOREIGN KEY (fk_id_building) REFERENCES buildings(id_building)
);

CREATE TABLE dining_room(
  id_dining_room INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  fk_id_building INT NOT NULL,
  start_service TIME NOT NULL,
  end_service TIME NOT NULL,
  CONSTRAINT fk_dr_building FOREIGN KEY (fk_id_building) REFERENCES buildings(id_building),
  CONSTRAINT chk_dining_times CHECK (end_service > start_service)
);

CREATE TABLE food_dining(
  id_food_dining INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  fk_dining_room INT NOT NULL,
  fk_id_foods INT NOT NULL,
  CONSTRAINT fk_fd_dining_room FOREIGN KEY (fk_dining_room) REFERENCES dining_room(id_dining_room),
  CONSTRAINT fk_fd_food FOREIGN KEY (fk_id_foods) REFERENCES food_catalog(id_foods),
  CONSTRAINT uq_food_dining UNIQUE (fk_dining_room, fk_id_foods)
);

CREATE TABLE security(
  id_security INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  fk_id_employee INT NOT NULL,
  assignment_area VARCHAR(200) NOT NULL,
  CONSTRAINT fk_sec_employee FOREIGN KEY (fk_id_employee) REFERENCES employees(id_employee)
);

CREATE TABLE residences(
  id_residence INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  address VARCHAR(200) NOT NULL,
  capacity INT NOT NULL CHECK (capacity > 0)
);

CREATE TABLE rooms(
  id_room INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(20) NOT NULL,
  fk_id_residence INT NOT NULL,
  CONSTRAINT fk_room_residence FOREIGN KEY (fk_id_residence) REFERENCES residences(id_residence),
  CONSTRAINT uq_room UNIQUE (code, fk_id_residence)
);

CREATE TABLE room_assignment(
  id_room_assignment INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  fk_id_room INT NOT NULL,
  fk_id_student INT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE,
  status room_assignment_type NOT NULL DEFAULT 'Assigned',
  CONSTRAINT fk_ra_room FOREIGN KEY (fk_id_room) REFERENCES rooms(id_room),
  CONSTRAINT fk_ra_student FOREIGN KEY (fk_id_student) REFERENCES students(id_student),
  CONSTRAINT chk_room_dates CHECK (end_date IS NULL OR end_date > start_date)
);

CREATE TABLE coaches(
  id_coach INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  fk_employee_id INT NOT NULL UNIQUE,
  specialization VARCHAR(100),
  coaching_license VARCHAR(100),
  certification_date DATE,
  years_coach INT CHECK (years_coach >= 0),
  CONSTRAINT fk_coach_employee FOREIGN KEY (fk_employee_id) REFERENCES employees(id_employee)
);

CREATE TABLE sport_team(
  id_sport_team INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  fk_id_sport INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  fk_coach_id INT,
  academic_year VARCHAR(9),
  CONSTRAINT fk_st_sport FOREIGN KEY (fk_id_sport) REFERENCES sports(id_sport),
  CONSTRAINT fk_st_coach FOREIGN KEY (fk_coach_id) REFERENCES coaches(id_coach)
);

CREATE TABLE student_athletes(
  id_student_athletes INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  fk_id_student INT NOT NULL,
  fk_id_sport_team INT NOT NULL,
  jersey_number VARCHAR(10),
  position VARCHAR(100),
  start_date DATE,
  end_date DATE,
  CONSTRAINT fk_sa_student FOREIGN KEY (fk_id_student) REFERENCES students(id_student),
  CONSTRAINT fk_sa_sport_team FOREIGN KEY (fk_id_sport_team) REFERENCES sport_team(id_sport_team),
  CONSTRAINT uq_athlete_team UNIQUE (fk_id_student, fk_id_sport_team)
);

CREATE TABLE team_coaches(
  id_team_coaches INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  fk_id_sport_team INT NOT NULL,
  fk_id_coach INT NOT NULL,
  role VARCHAR(100),
  start_date DATE,
  CONSTRAINT fk_tc_sport_team FOREIGN KEY (fk_id_sport_team) REFERENCES sport_team(id_sport_team),
  CONSTRAINT fk_tc_coach FOREIGN KEY (fk_id_coach) REFERENCES coaches(id_coach),
  CONSTRAINT uq_team_coach UNIQUE (fk_id_sport_team, fk_id_coach)
);

CREATE TABLE staff(
  id_staff INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  fk_id_employee INT NOT NULL UNIQUE,
  CONSTRAINT fk_staff_employee FOREIGN KEY (fk_id_employee) REFERENCES employees(id_employee)
);

CREATE TABLE staff_roles(
  id_staff_roles INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  fk_id_staff INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  CONSTRAINT fk_sr_staff FOREIGN KEY (fk_id_staff) REFERENCES staff(id_staff)
);

CREATE TABLE services_staff(
  id_services_staff INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  fk_id_staff INT NOT NULL,
  fk_id_service INT NOT NULL,
  CONSTRAINT fk_ss_staff FOREIGN KEY (fk_id_staff) REFERENCES staff(id_staff),
  CONSTRAINT fk_ss_service FOREIGN KEY (fk_id_service) REFERENCES services(id_services),
  CONSTRAINT uq_services_staff UNIQUE (fk_id_staff, fk_id_service)
);

CREATE TABLE scholarships(
  id_scholarship INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name_scholarship VARCHAR(200) NOT NULL,
  fk_id_type_scholarship INT NOT NULL,
  benefactor VARCHAR(200),
  discount_percentage DECIMAL(5,2) NOT NULL CHECK (discount_percentage > 0 AND discount_percentage <= 100),
  CONSTRAINT fk_sch_type FOREIGN KEY (fk_id_type_scholarship) REFERENCES type_scholarship(id_type_scholarship)
);

CREATE TABLE student_scholarship(
  id_student_scholarship INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  fk_id_student INT NOT NULL,
  fk_id_scholarship INT NOT NULL,
  CONSTRAINT fk_ss2_student FOREIGN KEY (fk_id_student) REFERENCES students(id_student),
  CONSTRAINT fk_ss2_scholarship FOREIGN KEY (fk_id_scholarship) REFERENCES scholarships(id_scholarship),
  CONSTRAINT uq_student_scholarship UNIQUE (fk_id_student, fk_id_scholarship)
);

CREATE TABLE tuition_rate(
  id_tuition_rate INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  cost_per_credit DECIMAL(10,2) NOT NULL CHECK (cost_per_credit > 0),
  date DATE NOT NULL,
  fk_id_student INT,
  fk_id_semester INT NOT NULL,
  fk_id_degree INT NOT NULL,
  CONSTRAINT fk_tr_student FOREIGN KEY (fk_id_student) REFERENCES students(id_student),
  CONSTRAINT fk_tr_semester FOREIGN KEY (fk_id_semester) REFERENCES semesters(id_semester),
  CONSTRAINT fk_tr_degree FOREIGN KEY (fk_id_degree) REFERENCES degrees(id_degree)
);

CREATE TABLE student_bill(
  id_student_bill INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  fk_id_student INT NOT NULL,
  fk_id_semester INT NOT NULL,
  fk_id_tuition_rate INT NOT NULL,
  total_credits INT NOT NULL CHECK (total_credits >= 0),
  subtotal DECIMAL(10,2) NOT NULL,
  scholarship_discount DECIMAL(10,2) NOT NULL DEFAULT 0,
  total_due DECIMAL(10,2) NOT NULL,
  due_date DATE NOT NULL,
  status student_bill_status NOT NULL DEFAULT 'Pending',
  CONSTRAINT fk_sb_student FOREIGN KEY (fk_id_student) REFERENCES students(id_student),
  CONSTRAINT fk_sb_semester FOREIGN KEY (fk_id_semester) REFERENCES semesters(id_semester),
  CONSTRAINT fk_sb_tuition_rate FOREIGN KEY (fk_id_tuition_rate) REFERENCES tuition_rate(id_tuition_rate)
);

CREATE TABLE total_payment(
  id_payment INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  fk_id_student_bill INT NOT NULL,
  amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
  payment_date DATE NOT NULL DEFAULT CURRENT_DATE,
  payment_method payment_method NOT NULL,
  reference_code VARCHAR(100) UNIQUE,
  fk_id_scholarship INT,
  CONSTRAINT fk_tp_student_bill FOREIGN KEY (fk_id_student_bill) REFERENCES student_bill(id_student_bill),
  CONSTRAINT fk_tp_scholarship FOREIGN KEY (fk_id_scholarship) REFERENCES scholarships(id_scholarship)
);

CREATE TABLE users(
  id_users INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL,
  role user_role NOT NULL,
  account_status account_status NOT NULL DEFAULT 'Active',
  fk_id_student INT,
  fk_id_employee INT,
  CONSTRAINT fk_users_student FOREIGN KEY (fk_id_student) REFERENCES students(id_student),
  CONSTRAINT fk_users_employee FOREIGN KEY (fk_id_employee) REFERENCES employees(id_employee),
  CONSTRAINT chk_user_entity CHECK (
    (fk_id_student IS NOT NULL AND fk_id_employee IS NULL) OR
    (fk_id_student IS NULL AND fk_id_employee IS NOT NULL) OR
    (fk_id_student IS NULL AND fk_id_employee IS NULL)
  )
);
