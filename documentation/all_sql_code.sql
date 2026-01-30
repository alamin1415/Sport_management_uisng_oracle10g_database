    -- ============================================
    -- AIUB Sports Portal - Complete Database Schema
    -- Oracle 10g PL/SQL
    -- Version 1.3
    -- ============================================

    -- ============================================
    -- 1. SEQUENCES
    -- ============================================

    -- Sequence for user IDs
    CREATE SEQUENCE user_id_seq
        START WITH 1
        INCREMENT BY 1
        NOCACHE
        NOCYCLE;

    -- Sequence for admin IDs
    CREATE SEQUENCE admin_id_seq 
        START WITH 1
        INCREMENT BY 1
        NOCACHE
        NOCYCLE;

    -- Sequence for tournament IDs
    CREATE SEQUENCE tournament_id_seq
        START WITH 1
        INCREMENT BY 1
        NOCACHE
        NOCYCLE;

    -- Sequence for game IDs
    CREATE SEQUENCE game_id_seq
        START WITH 1
        INCREMENT BY 1
        NOCACHE
        NOCYCLE;

    -- Sequence for registration IDs
    CREATE SEQUENCE registration_id_seq
        START WITH 1
        INCREMENT BY 1
        NOCACHE
        NOCYCLE;

    -- ============================================
    -- 2. TABLES
    -- ============================================

    -- Users table - stores student information
    CREATE TABLE users (
        id NUMBER PRIMARY KEY,                    -- Unique user ID (auto-generated)
        student_id VARCHAR2(50) NOT NULL UNIQUE,  -- AIUB student ID (XX-XXXXX-X format)
        email VARCHAR2(100) NOT NULL UNIQUE,      -- Student email (XX-XXXXX-X@student.aiub.edu)
        full_name VARCHAR2(200),                  -- Student's full name
        gender VARCHAR2(20),                      -- Gender (Male, Female, Other)
        phone_number VARCHAR2(20),                -- Phone number
        program_level VARCHAR2(20),               -- Undergraduate or Postgraduate
        department VARCHAR2(100),                 -- Department name
        blood_group VARCHAR2(5),                  -- Blood group (A+, A-, etc.)
        name_edit_count NUMBER DEFAULT 0,         -- Count of name changes (max 3)
        is_first_login NUMBER(1) DEFAULT 1,       -- Flag for first-time login
        profile_completed NUMBER(1) DEFAULT 0,    -- Flag for profile completion
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Record creation time
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Record update time
        last_login TIMESTAMP,                     -- Last login time
        
        -- Constraints
        CONSTRAINT chk_gender CHECK (gender IN ('Male', 'Female', 'Other', NULL)),
        CONSTRAINT chk_edit_count CHECK (name_edit_count >= 0 AND name_edit_count <= 3),
        CONSTRAINT chk_first_login CHECK (is_first_login IN (0, 1)),
        CONSTRAINT chk_program_level CHECK (program_level IN ('Undergraduate', 'Postgraduate', NULL)),
        CONSTRAINT chk_blood_group CHECK (blood_group IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', NULL))
    );

    -- Admins table - stores admin information
    CREATE TABLE admins (
        id NUMBER PRIMARY KEY,                    -- Unique admin ID (auto-generated)
        admin_id VARCHAR2(50) NOT NULL UNIQUE,    -- Admin ID
        email VARCHAR2(100) NOT NULL UNIQUE,      -- Admin email
        full_name VARCHAR2(200),                  -- Admin's full name
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP  -- Record creation time
    );

    -- Tournaments table - stores tournament information
    CREATE TABLE tournaments (
        id NUMBER PRIMARY KEY,                    -- Unique tournament ID (auto-generated)
        title VARCHAR2(300) NOT NULL,             -- Tournament title
        photo_url CLOB,                           -- Tournament photo (stored as CLOB)
        registration_deadline TIMESTAMP NOT NULL, -- Deadline for registration
        status VARCHAR2(20) DEFAULT 'ACTIVE',     -- Tournament status (ACTIVE, CLOSED, COMPLETED)
        created_by NUMBER REFERENCES admins(id),  -- Admin who created the tournament
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Record creation time
        description CLOB,                         -- Tournament description
        
        -- Constraint for tournament status
        CONSTRAINT chk_tournament_status CHECK (status IN ('ACTIVE', 'CLOSED', 'COMPLETED'))
    );

    -- Tournament Games table - stores games within each tournament
    CREATE TABLE tournament_games (
        id NUMBER PRIMARY KEY,                    -- Unique game ID (auto-generated)
        tournament_id NUMBER NOT NULL REFERENCES tournaments(id) ON DELETE CASCADE,  -- Tournament ID
        category VARCHAR2(20) NOT NULL,           -- Category (Male, Female, Mix)
        game_name VARCHAR2(200) NOT NULL,         -- Name of the game
        game_type VARCHAR2(50) NOT NULL,          -- Type of game (Solo, Duo, Custom)
        fee_per_person NUMBER NOT NULL,           -- Registration fee per person
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Record creation time
        
        -- Constraints for category and game type
        CONSTRAINT chk_game_category CHECK (category IN ('Male', 'Female', 'Mix')),
        CONSTRAINT chk_game_type CHECK (game_type IN ('Solo', 'Duo', 'Custom'))
    );

    -- Game Registrations table - stores user registrations for games
    CREATE TABLE game_registrations (
        id NUMBER PRIMARY KEY,                    -- Unique registration ID (auto-generated)
        game_id NUMBER NOT NULL REFERENCES tournament_games(id) ON DELETE CASCADE,  -- Game ID
        user_id NUMBER NOT NULL REFERENCES users(id),  -- User ID
        registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Registration date
        payment_status VARCHAR2(20) DEFAULT 'PENDING',  -- Payment status (PENDING, PAID, FAILED)
        
        -- Constraint for payment status
        CONSTRAINT chk_payment_status CHECK (payment_status IN ('PENDING', 'PAID', 'FAILED'))
    );

    -- ============================================
    -- 3. INDEXES
    -- ============================================

    -- Indexes for faster lookups
    CREATE INDEX idx_student_id ON users(student_id);
    CREATE INDEX idx_email ON users(email);
    CREATE INDEX idx_tournament_deadline ON tournaments(registration_deadline);

    -- ============================================
    -- 4. TRIGGERS
    -- ============================================

    -- Trigger to automatically set ID using sequence for users table
    CREATE OR REPLACE TRIGGER users_bir
    BEFORE INSERT ON users
    FOR EACH ROW
    BEGIN
        IF :new.id IS NULL THEN
            SELECT user_id_seq.NEXTVAL INTO :new.id FROM dual;
        END IF;
    END;
    /

    -- Trigger to update 'updated_at' timestamp for users table
    CREATE OR REPLACE TRIGGER users_bur
    BEFORE UPDATE ON users
    FOR EACH ROW
    BEGIN
        :new.updated_at := CURRENT_TIMESTAMP;
    END;
    /

    -- Trigger to automatically set ID using sequence for admins table
    CREATE OR REPLACE TRIGGER admins_bir
    BEFORE INSERT ON admins FOR EACH ROW
    BEGIN
        IF :new.id IS NULL THEN
            SELECT admin_id_seq.NEXTVAL INTO :new.id FROM dual;
        END IF;
    END;
    /

    -- Trigger to automatically set ID using sequence for tournaments table
    CREATE OR REPLACE TRIGGER tournaments_bir
    BEFORE INSERT ON tournaments FOR EACH ROW
    BEGIN
        IF :new.id IS NULL THEN
            SELECT tournament_id_seq.NEXTVAL INTO :new.id FROM dual;
        END IF;
    END;
    /

    -- Trigger to automatically set ID using sequence for tournament_games table
    CREATE OR REPLACE TRIGGER games_bir
    BEFORE INSERT ON tournament_games FOR EACH ROW
    BEGIN
        IF :new.id IS NULL THEN
            SELECT game_id_seq.NEXTVAL INTO :new.id FROM dual;
        END IF;
    END;
    /

    -- Trigger to automatically set ID using sequence for game_registrations table
    CREATE OR REPLACE TRIGGER registrations_bir
    BEFORE INSERT ON game_registrations FOR EACH ROW
    BEGIN
        IF :new.id IS NULL THEN
            SELECT registration_id_seq.NEXTVAL INTO :new.id FROM dual;
        END IF;
    END;
    /

    -- ============================================
    -- 5. FUNCTIONS
    -- ============================================

    -- Function to validate AIUB email format
    -- Returns 1 if valid, 0 if invalid
    CREATE OR REPLACE FUNCTION validate_aiub_email(p_email IN VARCHAR2)
    RETURN NUMBER
    IS
        v_pattern VARCHAR2(100) := '^\d{2}-\d{5}-\d@student\.aiub\.edu$';
    BEGIN
        -- Use REGEXP_LIKE to check if email matches the AIUB format (XX-XXXXX-X@student.aiub.edu)
        IF REGEXP_LIKE(p_email, v_pattern) THEN
            RETURN 1; -- Valid
        ELSE
            RETURN 0; -- Invalid
        END IF;
    END;
    /

    -- Function to get user profile
    -- Returns a cursor with user information
    CREATE OR REPLACE FUNCTION get_user_profile(p_student_id IN VARCHAR2)
    RETURN SYS_REFCURSOR
    IS
        v_cursor SYS_REFCURSOR;
    BEGIN
        -- Open cursor to return user profile information
        OPEN v_cursor FOR
            SELECT
                id,
                student_id,
                email,
                full_name,
                gender,
                phone_number,
                program_level,
                department,
                blood_group,
                name_edit_count,
                is_first_login,
                profile_completed,
                created_at,
                updated_at,
                last_login
            FROM users
            WHERE student_id = p_student_id;

        RETURN v_cursor;
    END;
    /

    -- ============================================
    -- 6. PROCEDURES
    -- ============================================

    -- Procedure to register new user
    -- Parameters:
    --   p_student_id - Student ID in AIUB format
    --   p_email - Student email in AIUB format
    --   p_user_id - Output parameter for the created user ID
    --   p_status - Output parameter for status message
    CREATE OR REPLACE PROCEDURE register_user(
        p_student_id IN VARCHAR2,
        p_email IN VARCHAR2,
        p_user_id OUT NUMBER,
        p_status OUT VARCHAR2
    )
    IS
        v_count NUMBER;
        v_valid NUMBER;
    BEGIN
        -- Validate email format using the validate_aiub_email function
        v_valid := validate_aiub_email(p_email);

        IF v_valid = 0 THEN
            p_status := 'INVALID_EMAIL';
            RETURN;
        END IF;

        -- Check if user already exists (by student_id or email)
        SELECT COUNT(*) INTO v_count
        FROM users
        WHERE student_id = p_student_id OR email = p_email;

        IF v_count > 0 THEN
            -- User already exists, return existing ID
            p_status := 'USER_EXISTS';
            SELECT id INTO p_user_id FROM users WHERE student_id = p_student_id;
        ELSE
            -- Insert new user with first login flag set
            INSERT INTO users (student_id, email, is_first_login, last_login)
            VALUES (p_student_id, p_email, 1, CURRENT_TIMESTAMP)
            RETURNING id INTO p_user_id;

            COMMIT;
            p_status := 'SUCCESS';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_status := 'ERROR: ' || SQLERRM;
            ROLLBACK;
    END;
    /

    -- Procedure to update user profile
    -- Parameters:
    --   p_student_id - Student ID of the user to update
    --   p_full_name - New full name
    --   p_gender - New gender
    --   p_phone_number - New phone number
    --   p_blood_group - New blood group
    --   p_program_level - New program level
    --   p_department - New department
    --   p_is_first_time - Flag indicating if this is first-time profile completion
    --   p_status - Output parameter for status message
    CREATE OR REPLACE PROCEDURE update_user_profile(
        p_student_id IN VARCHAR2,
        p_full_name IN VARCHAR2,
        p_gender IN VARCHAR2,
        p_phone_number IN VARCHAR2,
        p_blood_group IN VARCHAR2,
        p_program_level IN VARCHAR2,
        p_department IN VARCHAR2,
        p_is_first_time IN NUMBER,
        p_status OUT VARCHAR2
    )
    IS
        v_current_count NUMBER;
        v_current_name VARCHAR2(200);
        v_current_program_level VARCHAR2(20);
        v_current_department VARCHAR2(100);
        v_is_first NUMBER;
    BEGIN
        -- Get current user data
        SELECT name_edit_count, full_name, program_level, department, is_first_login
        INTO v_current_count, v_current_name, v_current_program_level, v_current_department, v_is_first
        FROM users
        WHERE student_id = p_student_id;

        -- First time profile completion
        IF p_is_first_time = 1 THEN
            UPDATE users
            SET full_name = p_full_name,
                gender = p_gender,
                phone_number = p_phone_number,
                blood_group = p_blood_group,
                program_level = p_program_level,
                department = p_department,
                is_first_login = 0,
                profile_completed = 1,
                name_edit_count = 0,
                last_login = CURRENT_TIMESTAMP
            WHERE student_id = p_student_id;

            COMMIT;
            p_status := 'PROFILE_CREATED';
            RETURN;
        END IF;

        -- Subsequent updates - check locked fields
        -- Check if program level is being changed (locked after first submission)
        IF p_program_level IS NOT NULL AND v_current_program_level IS NOT NULL AND v_current_program_level != p_program_level THEN
            p_status := 'PROGRAM_LEVEL_LOCKED';
            RETURN;
        END IF;

        -- Check if department is being changed (locked after first submission)
        IF p_department IS NOT NULL AND v_current_department IS NOT NULL AND v_current_department != p_department THEN
            p_status := 'DEPARTMENT_LOCKED';
            RETURN;
        END IF;

        -- Subsequent updates for other fields
        DECLARE
            v_update_fields VARCHAR2(1000) := '';
            v_sql VARCHAR2(2000);
        BEGIN
            -- Check if name is being changed
            IF v_current_name != p_full_name THEN
                IF v_current_count >= 3 THEN
                    p_status := 'NAME_EDIT_LIMIT_REACHED';
                    RETURN;
                END IF;

                v_update_fields := v_update_fields || ', full_name = :full_name, name_edit_count = name_edit_count + 1';
            END IF;

            -- Update other editable fields
            v_update_fields := v_update_fields || 
                ', phone_number = :phone_number' ||
                ', blood_group = :blood_group' ||
                ', last_login = CURRENT_TIMESTAMP';

            -- Build and execute dynamic SQL for updates
            v_sql := 'UPDATE users SET ' || 
                    SUBSTR(v_update_fields, 3) ||  -- Remove leading comma and space
                    ' WHERE student_id = :student_id';

            EXECUTE IMMEDIATE v_sql
            USING p_full_name, p_phone_number, p_blood_group, p_student_id;

            COMMIT;
            p_status := 'PROFILE_UPDATED';
        END;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_status := 'USER_NOT_FOUND';
        WHEN OTHERS THEN
            p_status := 'ERROR: ' || SQLERRM;
            ROLLBACK;
    END;
    /

    -- ============================================
    -- 7. SAMPLE DATA
    -- ============================================

    -- Insert a test admin user
    INSERT INTO admins (admin_id, email, full_name)
    VALUES ('admin001', 'admin@aiub.edu', 'System Admin');

    -- Insert a test user (for testing purposes)
    -- Note: This user would normally be created through the registration process
    -- which validates the email format
    BEGIN
        DECLARE
            v_user_id NUMBER;
            v_status VARCHAR2(100);
        BEGIN
            -- Register a test user
            register_user('24-56434-1', '24-56434-1@student.aiub.edu', v_user_id, v_status);
            DBMS_OUTPUT.PUT_LINE('Test User Registration: ' || v_status);
        END;
    END;
    /

    -- ============================================
    -- 8. VIEWS (Optional)
    -- ============================================

    -- View to get user registration details with tournament and game information
    CREATE OR REPLACE VIEW user_registration_details AS
    SELECT
        gr.id AS registration_id,
        u.student_id,
        u.full_name,
        t.id AS tournament_id,
        t.title AS tournament_title,
        tg.id AS game_id,
        tg.game_name,
        tg.category,
        tg.game_type,
        tg.fee_per_person,
        gr.registration_date,
        gr.payment_status
    FROM game_registrations gr
    JOIN users u ON gr.user_id = u.id
    JOIN tournament_games tg ON gr.game_id = tg.id
    JOIN tournaments t ON tg.tournament_id = t.id;

    -- ============================================
    -- 9. ADDITIONAL UTILITIES
    -- ============================================

    -- Function to check if registration deadline has passed for a specific game
    CREATE OR REPLACE FUNCTION is_registration_open(p_game_id IN NUMBER)
    RETURN NUMBER
    IS
        v_deadline TIMESTAMP;
    BEGIN
        -- Get the registration deadline for the tournament associated with this game
        SELECT t.registration_deadline
        INTO v_deadline
        FROM tournament_games tg
        JOIN tournaments t ON tg.tournament_id = t.id
        WHERE tg.id = p_game_id;

        -- Return 1 if registration is still open, 0 if deadline has passed
        IF v_deadline > CURRENT_TIMESTAMP THEN
            RETURN 1;
        ELSE
            RETURN 0;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN -1; -- Game not found
    END;
    /

    -- Procedure to get user's registration count for a specific tournament
    CREATE OR REPLACE PROCEDURE get_user_tournament_registrations(
        p_student_id IN VARCHAR2,
        p_tournament_id IN NUMBER,
        p_count OUT NUMBER
    )
    IS
        v_user_id NUMBER;
    BEGIN
        -- Get user ID from student ID
        SELECT id INTO v_user_id
        FROM users
        WHERE student_id = p_student_id;

        -- Count user's registrations for the specified tournament
        SELECT COUNT(*)
        INTO p_count
        FROM game_registrations gr
        JOIN tournament_games tg ON gr.game_id = tg.id
        WHERE gr.user_id = v_user_id
        AND tg.tournament_id = p_tournament_id;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_count := 0;
    END;
    /

    -- Verify installation
    SELECT 'Complete schema created successfully!' AS status FROM dual;
    SELECT COUNT(*) AS total_users FROM users;
    SELECT COUNT(*) AS total_admins FROM admins;
    SELECT COUNT(*) AS total_tournaments FROM tournaments;
    SELECT COUNT(*) AS total_games FROM tournament_games;
    SELECT COUNT(*) AS total_registrations FROM game_registrations;

    COMMIT;