-- Supper Club database: SQLite schema.sql 
-- 7 entity sets and 5 M:N relationship tables
-- Dates stored as TEXT in YYYYMMDD format


--  Entity sets 

CREATE TABLE MEMBER (
    member_id    INTEGER PRIMARY KEY,
    name         TEXT NOT NULL,
    email        TEXT NOT NULL UNIQUE,
    phone        TEXT,
    joined_date  TEXT NOT NULL
);

CREATE TABLE EVENT (
    event_id     INTEGER PRIMARY KEY,
    title        TEXT NOT NULL,
    event_date   TEXT NOT NULL,
    location     TEXT NOT NULL,
    max_guests   INTEGER NOT NULL CHECK (max_guests > 0)
);

CREATE TABLE DIETARY_RESTRICTION (
    restriction_id  INTEGER PRIMARY KEY,
    name            TEXT NOT NULL UNIQUE,
    kind            TEXT NOT NULL
                    CHECK (kind IN ('allergy', 'intolerance', 'preference'))
);

-- 1:1 with EVENT, MENU is total (every menu belongs to exactly one event)
CREATE TABLE MENU (
    menu_id    INTEGER PRIMARY KEY,
    name       TEXT NOT NULL,
    event_id   INTEGER NOT NULL UNIQUE,
    FOREIGN KEY (event_id) REFERENCES EVENT (event_id)
);

-- 1:N with MENU, DISH is total (every dish belongs to exactly one menu)
CREATE TABLE DISH (
    dish_id      INTEGER PRIMARY KEY,
    name         TEXT NOT NULL,
    description  TEXT,
    course       TEXT NOT NULL
                 CHECK (course IN ('starter', 'main', 'dessert', 'side', 'drink')),
    menu_id      INTEGER NOT NULL,
    FOREIGN KEY (menu_id) REFERENCES MENU (menu_id)
);

-- MEMBER 1:N PAYMENT (pays) and EVENT 1:N PAYMENT (for_event), PAYMENT total in both
CREATE TABLE PAYMENT (
    payment_id  INTEGER PRIMARY KEY,
    amount      REAL NOT NULL CHECK (amount >= 0),
    method      TEXT NOT NULL,
    status      TEXT NOT NULL
                CHECK (status IN ('pending', 'paid', 'refunded')),
    paid_on     TEXT,
    member_id   INTEGER NOT NULL,
    event_id    INTEGER NOT NULL,
    FOREIGN KEY (member_id) REFERENCES MEMBER (member_id),
    FOREIGN KEY (event_id)  REFERENCES EVENT (event_id)
);

-- MEMBER 1:N GUEST (invites), GUEST total
CREATE TABLE GUEST (
    guest_id    INTEGER PRIMARY KEY,
    name        TEXT NOT NULL,
    email       TEXT,
    invited_by  INTEGER NOT NULL,
    FOREIGN KEY (invited_by) REFERENCES MEMBER (member_id)
);

--  M:N relationship sets 

-- attends: MEMBER M:N EVENT
CREATE TABLE ATTENDANCE (
    member_id    INTEGER NOT NULL,
    event_id     INTEGER NOT NULL,
    seat_no      INTEGER,
    rsvp_status  TEXT NOT NULL
                 CHECK (rsvp_status IN ('invited', 'going', 'declined', 'attended')),
    PRIMARY KEY (member_id, event_id),
    FOREIGN KEY (member_id) REFERENCES MEMBER (member_id) ON DELETE CASCADE,
    FOREIGN KEY (event_id)  REFERENCES EVENT (event_id)   ON DELETE CASCADE
);

-- attends_as_guest: GUEST M:N EVENT
CREATE TABLE GUEST_ATTENDANCE (
    guest_id  INTEGER NOT NULL,
    event_id  INTEGER NOT NULL,
    PRIMARY KEY (guest_id, event_id),
    FOREIGN KEY (guest_id) REFERENCES GUEST (guest_id) ON DELETE CASCADE,
    FOREIGN KEY (event_id) REFERENCES EVENT (event_id) ON DELETE CASCADE
);

-- has_restriction: MEMBER M:N DIETARY_RESTRICTION
CREATE TABLE MEMBER_DIETARY (
    member_id       INTEGER NOT NULL,
    restriction_id  INTEGER NOT NULL,
    notes           TEXT,
    PRIMARY KEY (member_id, restriction_id),
    FOREIGN KEY (member_id)      REFERENCES MEMBER (member_id)                  ON DELETE CASCADE,
    FOREIGN KEY (restriction_id) REFERENCES DIETARY_RESTRICTION (restriction_id) ON DELETE CASCADE
);

-- guest_has: GUEST M:N DIETARY_RESTRICTION
CREATE TABLE GUEST_DIETARY (
    guest_id        INTEGER NOT NULL,
    restriction_id  INTEGER NOT NULL,
    notes           TEXT,
    PRIMARY KEY (guest_id, restriction_id),
    FOREIGN KEY (guest_id)       REFERENCES GUEST (guest_id)                    ON DELETE CASCADE,
    FOREIGN KEY (restriction_id) REFERENCES DIETARY_RESTRICTION (restriction_id) ON DELETE CASCADE
);

-- conflicts_with: DISH M:N DIETARY_RESTRICTION
CREATE TABLE DISH_CONFLICT (
    dish_id         INTEGER NOT NULL,
    restriction_id  INTEGER NOT NULL,
    PRIMARY KEY (dish_id, restriction_id),
    FOREIGN KEY (dish_id)        REFERENCES DISH (dish_id)                      ON DELETE CASCADE,
    FOREIGN KEY (restriction_id) REFERENCES DIETARY_RESTRICTION (restriction_id) ON DELETE CASCADE
);
