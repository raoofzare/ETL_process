CREATE TABLE BOOK_DETAIL (
	ISBN VARCHAR(13) PRIMARY KEY,
	publisher_name VARCHAR(50),
	publication_date DATE,
	Title VARCHAR(20),
	Description VARCHAR(200),
	version_number VARCHAR(10),
	is_translate BOOLEAN NOT NULL
);

CREATE TABLE BOOK_ID (
	book_id VARCHAR(5) PRIMARY KEY,
	isbn VARCHAR(13) NOT NULL,
	FOREIGN KEY(ISBN) 
    REFERENCES BOOK_DETAIL(ISBN)
);

CREATE TABLE Writer(
	w_id VARCHAR(13) PRIMARY KEY,
	isbn VARCHAR(13),
	writer_name VARCHAR(30),
	FOREIGN KEY(ISBN) 
    REFERENCES BOOK_DETAIL(ISBN)
);

CREATE TABLE GENRE(
	g_id VARCHAR(13) PRIMARY KEY,
	isbn VARCHAR(13),
	genre_name VARCHAR(20),
	FOREIGN KEY(ISBN) 
    REFERENCES BOOK_DETAIL(ISBN)
);

CREATE TABLE LANGUAGES(
	l_id VARCHAR(13) PRIMARY KEY,
	isbn VARCHAR(13),
	languages VARCHAR(20),
	FOREIGN KEY(ISBN) 
    REFERENCES BOOK_DETAIL(ISBN)
);


CREATE TABLE TRANSLATOR(
	t_id VARCHAR(13) PRIMARY KEY,
	isbn VARCHAR(13),
	translator VARCHAR(20),
	FOREIGN KEY(ISBN) 
    REFERENCES BOOK_DETAIL(ISBN)
);


CREATE TABLE SUBSCRIBER(
	membership_number VARCHAR(10) PRIMARY KEY,
	sub_name VARCHAR(50) NOT NULL,
	sub_address VARCHAR(100),
	sub_birth DATE,
	membership_date DATE,
	sub_mail VARCHAR(30),
	sub_phone VARCHAR(20)
);

CREATE TABLE BORROW(
	book_id VARCHAR(5) PRIMARY KEY,
	membership_number VARCHAR(10) NOT NULL,
	return_date DATE NOT NULL,
	FOREIGN KEY(book_id) 
    REFERENCES BOOK_ID(book_id),
	FOREIGN KEY(membership_number) 
    REFERENCES SUBSCRIBER(membership_number)
);


-- CREATE FUNCTION borrow_Change() RETURNS trigger AS $borrow_change$
-- BEGIN
--         IF (TG_OP = 'DELETE') THEN
--             UPDATE book_id 
-- 			set is_borrowed = false
-- 			where book_id = old.book_id;
--         ELSIF (TG_OP = 'INSERT') THEN
--             UPDATE book_id 
-- 			set is_borrowed = true
-- 			where book_id = new.book_id;
--         END IF;
--         RETURN NEW;
--     END;
-- $borrow_change$ LANGUAGE plpgsql;




-- CREATE TRIGGER borrow_change AFTER INSERT OR DELETE on borrow
-- 	FOR EACH ROW EXECUTE FUNCTION borrow_change();

