-- =============================================================
--  JAY-MART  –  Complete MySQL DDL
--  Tables are created in dependency order so every FK
--  references a table that already exists.
-- =============================================================

-- =============================================================
-- 1. SUPPLIER
--    No dependencies – created first.
-- =============================================================
CREATE TABLE supplier (
    supplier_id   INT            NOT NULL AUTO_INCREMENT,
    supplier_name VARCHAR(120)   NOT NULL,
    contact_name  VARCHAR(120)   NOT NULL,
    email         VARCHAR(180)   NOT NULL,
    phone         VARCHAR(30)    NOT NULL,

    CONSTRAINT pk_supplier      PRIMARY KEY (supplier_id),
    CONSTRAINT uq_supplier_name UNIQUE      (supplier_name),
    CONSTRAINT uq_supplier_email UNIQUE     (email)
);

-- =============================================================
-- 2. EMPLOYEE  (forward-declared before DEPARTMENT
--    because DEPARTMENT.manager_id references EMPLOYEE)
-- =============================================================
CREATE TABLE employee (
    employee_id   INT            NOT NULL AUTO_INCREMENT,
    first_name    VARCHAR(80)    NOT NULL,
    last_name     VARCHAR(80)    NOT NULL,
    email         VARCHAR(180)   NOT NULL,
    role          VARCHAR(60)    NOT NULL,
    salary        DECIMAL(10,2)  NOT NULL,
    hire_date     DATE           NOT NULL,
    department_id INT            NOT NULL,          -- FK added via ALTER below

    CONSTRAINT pk_employee       PRIMARY KEY (employee_id),
    CONSTRAINT uq_employee_email UNIQUE      (email),
    CONSTRAINT ck_employee_salary CHECK      (salary > 0)
);

-- =============================================================
-- 3. DEPARTMENT
--    manager_id references EMPLOYEE (nullable – no manager yet).
-- =============================================================
CREATE TABLE department (
    department_id INT          NOT NULL AUTO_INCREMENT,
    name          VARCHAR(100) NOT NULL,
    manager_id    INT              NULL,             -- optional manager

    CONSTRAINT pk_department      PRIMARY KEY (department_id),
    CONSTRAINT uq_department_name UNIQUE      (name),
    CONSTRAINT fk_dept_manager    FOREIGN KEY (manager_id)
        REFERENCES employee (employee_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

-- =============================================================
-- 4. Back-fill the FK from EMPLOYEE → DEPARTMENT
--    (needed because the two tables reference each other)
-- =============================================================
ALTER TABLE employee
    ADD CONSTRAINT fk_emp_department
        FOREIGN KEY (department_id)
        REFERENCES department (department_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT;

-- =============================================================
-- 5. ATTENDANCE  (weak entity – depends on EMPLOYEE)
-- =============================================================
CREATE TABLE attendance (
    attendance_id INT         NOT NULL AUTO_INCREMENT,
    employee_id   INT         NOT NULL,
    work_date     DATE        NOT NULL,
    clock_in      TIME        NOT NULL,
    clock_out     TIME            NULL,              -- nullable: employee may not have clocked out yet
    status        VARCHAR(10) NOT NULL,

    CONSTRAINT pk_attendance       PRIMARY KEY (attendance_id),
    CONSTRAINT uq_attendance_daily UNIQUE      (employee_id, work_date),
    CONSTRAINT fk_attend_employee  FOREIGN KEY (employee_id)
        REFERENCES employee (employee_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT ck_attend_status    CHECK (status IN ('present', 'absent', 'late')),
    CONSTRAINT ck_attend_clockout  CHECK (clock_out IS NULL OR clock_out >= clock_in)
);

-- =============================================================
-- 6. CATEGORY  (depends on DEPARTMENT)
-- =============================================================
CREATE TABLE category (
    category_id   INT          NOT NULL AUTO_INCREMENT,
    name          VARCHAR(100) NOT NULL,
    department_id INT          NOT NULL,

    CONSTRAINT pk_category       PRIMARY KEY (category_id),
    CONSTRAINT uq_category_dept  UNIQUE      (name, department_id),
    CONSTRAINT fk_cat_department FOREIGN KEY (department_id)
        REFERENCES department (department_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- =============================================================
-- 7. PRODUCT  (depends on CATEGORY and SUPPLIER)
-- =============================================================
CREATE TABLE product (
    product_id      INT           NOT NULL AUTO_INCREMENT,
    name            VARCHAR(150)  NOT NULL,
    price           DECIMAL(10,2) NOT NULL,
    unit_of_measure VARCHAR(40)   NOT NULL,
    category_id     INT           NOT NULL,
    supplier_id     INT           NOT NULL,

    CONSTRAINT pk_product          PRIMARY KEY (product_id),
    CONSTRAINT uq_product_cat      UNIQUE      (name, category_id),
    CONSTRAINT fk_prod_category    FOREIGN KEY (category_id)
        REFERENCES category (category_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_prod_supplier    FOREIGN KEY (supplier_id)
        REFERENCES supplier (supplier_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT ck_product_price    CHECK (price > 0)
);

-- =============================================================
-- 8. INVENTORY  (weak entity – 1-to-1 with PRODUCT)
-- =============================================================
CREATE TABLE inventory (
    inventory_id      INT  NOT NULL AUTO_INCREMENT,
    product_id        INT  NOT NULL,
    quantity_on_hand  INT  NOT NULL DEFAULT 0,
    reorder_threshold INT  NOT NULL DEFAULT 0,
    last_restocked    DATE     NULL,

    CONSTRAINT pk_inventory           PRIMARY KEY (inventory_id),
    CONSTRAINT uq_inventory_product   UNIQUE      (product_id),         -- enforces 1-to-1
    CONSTRAINT fk_inv_product         FOREIGN KEY (product_id)
        REFERENCES product (product_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT ck_inv_qty             CHECK (quantity_on_hand  >= 0),
    CONSTRAINT ck_inv_reorder         CHECK (reorder_threshold >= 0)
);

-- =============================================================
-- 9. CUSTOMER
--    No FK dependencies on other domain tables.
-- =============================================================
CREATE TABLE customer (
    customer_id   INT          NOT NULL AUTO_INCREMENT,
    first_name    VARCHAR(80)  NOT NULL,
    last_name     VARCHAR(80)  NOT NULL,
    email         VARCHAR(180) NOT NULL,
    phone         VARCHAR(30)      NULL,
    loyalty_tier  VARCHAR(10)  NOT NULL DEFAULT 'standard',
    registered_at DATE         NOT NULL,

    CONSTRAINT pk_customer          PRIMARY KEY (customer_id),
    CONSTRAINT uq_customer_email    UNIQUE      (email),
    CONSTRAINT ck_customer_loyalty  CHECK (loyalty_tier IN ('standard', 'silver', 'gold'))
);

-- =============================================================
-- 10. TRANSACTION  (depends on CUSTOMER and EMPLOYEE)
-- =============================================================
CREATE TABLE transaction (
    transaction_id INT           NOT NULL AUTO_INCREMENT,
    customer_id    INT           NOT NULL,
    employee_id    INT           NOT NULL,
    transaction_dt DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_amount   DECIMAL(12,2) NOT NULL DEFAULT 0.00,

    CONSTRAINT pk_transaction       PRIMARY KEY (transaction_id),
    CONSTRAINT fk_txn_customer      FOREIGN KEY (customer_id)
        REFERENCES customer (customer_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_txn_employee      FOREIGN KEY (employee_id)
        REFERENCES employee (employee_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT ck_txn_total         CHECK (total_amount >= 0)
);

-- =============================================================
-- 11. TRANSACTION_LINE  (weak entity – depends on TRANSACTION and PRODUCT)
-- =============================================================
CREATE TABLE transaction_line (
    line_id        INT           NOT NULL AUTO_INCREMENT,
    transaction_id INT           NOT NULL,
    product_id     INT           NOT NULL,
    quantity       INT           NOT NULL,
    unit_price     DECIMAL(10,2) NOT NULL,

    CONSTRAINT pk_txn_line           PRIMARY KEY (line_id),
    CONSTRAINT uq_txn_line_product   UNIQUE      (transaction_id, product_id),
    CONSTRAINT fk_line_transaction   FOREIGN KEY (transaction_id)
        REFERENCES transaction (transaction_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_line_product       FOREIGN KEY (product_id)
        REFERENCES product (product_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT ck_line_quantity      CHECK (quantity   > 0),
    CONSTRAINT ck_line_unit_price    CHECK (unit_price > 0)
);

-- =============================================================
-- 12. PAYMENT  (weak entity – depends on TRANSACTION)
-- =============================================================
CREATE TABLE payment (
    payment_id     INT           NOT NULL AUTO_INCREMENT,
    transaction_id INT           NOT NULL,
    method         VARCHAR(20)   NOT NULL,
    amount         DECIMAL(10,2) NOT NULL,

    CONSTRAINT pk_payment          PRIMARY KEY (payment_id),
    CONSTRAINT fk_pay_transaction  FOREIGN KEY (transaction_id)
        REFERENCES transaction (transaction_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT ck_pay_method       CHECK (method IN ('cash', 'card', 'mobile', 'voucher')),
    CONSTRAINT ck_pay_amount       CHECK (amount > 0)
);

-- =============================================================
-- 13. PROMOTION
--    No FK dependencies on other domain tables.
-- =============================================================
CREATE TABLE promotion (
    promotion_id  INT           NOT NULL AUTO_INCREMENT,
    name          VARCHAR(150)  NOT NULL,
    discount_pct  DECIMAL(5,4)  NOT NULL,
    start_date    DATE          NOT NULL,
    end_date      DATE          NOT NULL,

    CONSTRAINT pk_promotion          PRIMARY KEY (promotion_id),
    CONSTRAINT uq_promotion_name     UNIQUE      (name),
    CONSTRAINT ck_promo_discount     CHECK (discount_pct > 0 AND discount_pct < 1),
    CONSTRAINT ck_promo_dates        CHECK (end_date > start_date)
);

-- =============================================================
-- 14. PRODUCT_PROMOTION  (weak/junction entity – many-to-many)
-- =============================================================
CREATE TABLE product_promotion (
    product_id   INT NOT NULL,
    promotion_id INT NOT NULL,

    CONSTRAINT pk_product_promotion  PRIMARY KEY (product_id, promotion_id),
    CONSTRAINT fk_pp_product         FOREIGN KEY (product_id)
        REFERENCES product (product_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_pp_promotion       FOREIGN KEY (promotion_id)
        REFERENCES promotion (promotion_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- =============================================================
-- END OF DDL
-- =============================================================
