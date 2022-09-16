CREATE TABLE BOOK_DETAIL (
	ISBN VARCHAR(13) PRIMARY KEY,
	publisher_name VARCHAR(50),
	publication_date DATE,
	Title VARCHAR(20),
	Description VARCHAR(200),
	version_number VARCHAR(10),
	is_translate BOOLEAN NOT NULL,
	time_add_to_main DATE
);

CREATE TABLE BOOK_DETAIL_HISTORY (
	hist_id SERIAL PRIMARY KEY,
	ISBN VARCHAR(13),
	publisher_name VARCHAR(50),
	publication_date DATE,
	Title VARCHAR(20),
	Description VARCHAR(200),
	version_number VARCHAR(10),
	is_translate BOOLEAN NOT NULL,
	time_add_to_main DATE,
	time_add_to_hist DATE,
	reason VARCHAR(10)
);

CREATE TABLE BOOK_ID (
	book_id VARCHAR(5) PRIMARY KEY,
	isbn VARCHAR(13) NOT NULL,
	time_add_to_main DATE,
	FOREIGN KEY(ISBN) 
    REFERENCES BOOK_DETAIL(ISBN)
);

CREATE TABLE BOOK_ID_HISTORY (
	hist_id SERIAL PRIMARY KEY,
	book_id VARCHAR(5),
	isbn VARCHAR(13) NOT NULL,
	time_add_to_main DATE,
	time_add_to_hist DATE,
	reason VARCHAR(10)
);

CREATE TABLE Writer(
	w_id VARCHAR(13) PRIMARY KEY,
	isbn VARCHAR(13),
	writer_name VARCHAR(30),
	time_add_to_main DATE,
	FOREIGN KEY(ISBN) 
    REFERENCES BOOK_DETAIL(ISBN)
);

CREATE TABLE Writer_HISTORY(
	hist_id SERIAL PRIMARY KEY,
	w_id VARCHAR(13),
	isbn VARCHAR(13),
	writer_name VARCHAR(30),
	time_add_to_main DATE,
	time_add_to_hist DATE,
	reason VARCHAR(10)
);

CREATE TABLE GENRE(
	g_id VARCHAR(13) PRIMARY KEY,
	isbn VARCHAR(13),
	genre_name VARCHAR(20),
	time_add_to_main DATE,
	FOREIGN KEY(ISBN) 
    REFERENCES BOOK_DETAIL(ISBN)
);

CREATE TABLE GENRE_HISTORY(
	hist_id SERIAL PRIMARY KEY,
	g_id VARCHAR(13),
	isbn VARCHAR(13),
	genre_name VARCHAR(20),
	time_add_to_main DATE,
	time_add_to_hist DATE,
	reason VARCHAR(10)
);


CREATE TABLE LANGUAGES(
	l_id VARCHAR(13) PRIMARY KEY,
	isbn VARCHAR(13),
	languages VARCHAR(20),
	time_add_to_main DATE,
	FOREIGN KEY(ISBN) 
    REFERENCES BOOK_DETAIL(ISBN)
);

CREATE TABLE LANGUAGES_HISTORY(
	hist_id SERIAL PRIMARY KEY,
	l_id VARCHAR(13),
	isbn VARCHAR(13),
	languages VARCHAR(20),
	time_add_to_main DATE,
	time_add_to_hist DATE,
	reason VARCHAR(10)
);


CREATE TABLE TRANSLATOR(
	t_id VARCHAR(13) PRIMARY KEY,
	isbn VARCHAR(13),
	translator VARCHAR(20),
	time_add_to_main DATE,
	FOREIGN KEY(ISBN) 
    REFERENCES BOOK_DETAIL(ISBN)
);

CREATE TABLE TRANSLATOR_HISTORY(
	hist_id SERIAL PRIMARY KEY,
	t_id VARCHAR(13),
	isbn VARCHAR(13),
	translator VARCHAR(20),
	time_add_to_main DATE,
	time_add_to_hist DATE,
	reason VARCHAR(10)
);


CREATE TABLE SUBSCRIBER(
	membership_number VARCHAR(10) PRIMARY KEY,
	sub_name VARCHAR(50) NOT NULL,
	sub_address VARCHAR(100),
	sub_birth DATE,
	membership_date DATE,
	sub_mail VARCHAR(30),
	sub_phone VARCHAR(20),
	time_add_to_main DATE
);

CREATE TABLE SUBSCRIBER_HISTORY(
	hist_id SERIAL PRIMARY KEY,
	membership_number VARCHAR(10),
	sub_name VARCHAR(50) NOT NULL,
	sub_address VARCHAR(100),
	sub_birth DATE,
	membership_date DATE,
	sub_mail VARCHAR(30),
	sub_phone VARCHAR(20),
	time_add_to_main DATE,
	time_add_to_hist DATE,
	reason VARCHAR(10)
);

CREATE TABLE BORROW(
	book_id VARCHAR(5) PRIMARY KEY,
	membership_number VARCHAR(10) NOT NULL,
	return_date DATE NOT NULL,
	time_add_to_main DATE,
	FOREIGN KEY(book_id) 
    REFERENCES BOOK_ID(book_id),
	FOREIGN KEY(membership_number) 
    REFERENCES SUBSCRIBER(membership_number)
);

CREATE TABLE BORROW_HISTORY(
	hist_id SERIAL PRIMARY KEY,
	book_id VARCHAR(5),
	membership_number VARCHAR(10) NOT NULL,
	return_date DATE NOT NULL,
	time_add_to_main DATE,
	time_add_to_hist DATE,
	reason VARCHAR(10)
);

--trigger for time_add_to_main in book_detail
CREATE FUNCTION add_time_1() RETURNS trigger AS $add_time_1$
BEGIN
         IF (TG_OP = 'DELETE') THEN
            INSERT INTO book_detail_history(isbn, publisher_name, publication_date, title, description, 
											version_number, is_translate, time_add_to_main, time_add_to_hist, reason)
			VALUES (old.isbn, old.publisher_name, old.publication_date, old.title, old.description,
					old.version_number, old.is_translate, old.time_add_to_main, CURRENT_DATE, 'DELETE');
		 ELSEIF (TG_OP = 'UPDATE') THEN
		 	INSERT INTO book_detail_history(isbn, publisher_name, publication_date, title, description, 
											version_number, is_translate, time_add_to_main, time_add_to_hist, reason)
			VALUES (old.isbn, old.publisher_name, old.publication_date, old.title, old.description,
					old.version_number, old.is_translate, old.time_add_to_main, CURRENT_DATE, 'UPDATE');
         END IF;
         RETURN NEW;
END;
$add_time_1$ LANGUAGE plpgsql;


CREATE TRIGGER book_detail_war AFTER UPDATE OR DELETE on book_detail
 	FOR EACH ROW EXECUTE FUNCTION add_time_1();
	
	

--trigger for time_add_to_main in book_id
CREATE FUNCTION add_time_2() RETURNS trigger AS $add_time_2$
BEGIN
         IF (TG_OP = 'DELETE') THEN
            INSERT INTO book_id_history(book_id, isbn, time_add_to_main, time_add_to_hist, reason)
			VALUES (old.book_id, old.isbn, old.time_add_to_main, CURRENT_DATE, 'DELETE');
		 ELSEIF (TG_OP = 'UPDATE') THEN
		 	INSERT INTO book_id_history(book_id, isbn, time_add_to_main, time_add_to_hist, reason)
			VALUES (old.book_id, old.isbn, old.time_add_to_main, CURRENT_DATE, 'UPDATE');
         END IF;
         RETURN NEW;
END;
$add_time_2$ LANGUAGE plpgsql;


CREATE TRIGGER book_id_war AFTER UPDATE OR DELETE on book_id
 	FOR EACH ROW EXECUTE FUNCTION add_time_2();
	
--trigger for time_add_to_main in borrow
CREATE FUNCTION add_time_3() RETURNS trigger AS $add_time_3$
BEGIN
         IF (TG_OP = 'DELETE') THEN
            INSERT INTO borrow_history(book_id, membership_number, return_date, time_add_to_main, time_add_to_hist, reason)
			VALUES (old.book_id, old.membership_number, old.return_date, old.time_add_to_main, CURRENT_DATE, 'DELETE');
		 ELSEIF (TG_OP = 'UPDATE') THEN
		 	INSERT INTO borrow_history(book_id, membership_number, return_date, time_add_to_main, time_add_to_hist, reason)
			VALUES (old.book_id, old.membership_number, old.return_date, old.time_add_to_main, CURRENT_DATE, 'UPDATE');
         END IF;
         RETURN NEW;
END;
$add_time_3$ LANGUAGE plpgsql;


CREATE TRIGGER borrow_war AFTER UPDATE OR DELETE on borrow
 	FOR EACH ROW EXECUTE FUNCTION add_time_3();
	
--trigger for time_add_to_main in genre
CREATE FUNCTION add_time_4() RETURNS trigger AS $add_time_4$
BEGIN
         IF (TG_OP = 'DELETE') THEN
            INSERT INTO genre_history(g_id, isbn, genre_name, time_add_to_main, time_add_to_hist, reason)
			VALUES (old.g_id, old.isbn, old.genre_name, old.time_add_to_main, CURRENT_DATE, 'DELETE');
		 ELSEIF (TG_OP = 'UPDATE') THEN
		 	INSERT INTO genre_history(g_id, isbn, genre_name, time_add_to_main, time_add_to_hist, reason)
			VALUES (old.g_id, old.isbn, old.genre_name, old.time_add_to_main, CURRENT_DATE, 'UPDATE');
         END IF;
         RETURN NEW;
END;
$add_time_4$ LANGUAGE plpgsql;


CREATE TRIGGER genre_war AFTER UPDATE OR DELETE on genre
 	FOR EACH ROW EXECUTE FUNCTION add_time_4();
	
--trigger for time_add_to_main in languages
CREATE FUNCTION add_time_5() RETURNS trigger AS $add_time_5$
BEGIN 
         IF (TG_OP = 'DELETE') THEN
            INSERT INTO languages_history(l_id, isbn, languages, time_add_to_main, time_add_to_hist, reason)
			VALUES (old.l_id, old.isbn, old.languages, old.time_add_to_main, CURRENT_DATE, 'DELETE');
		 ELSEIF (TG_OP = 'UPDATE') THEN
		 	INSERT INTO languages_history(l_id, isbn, languages, time_add_to_main, time_add_to_hist, reason)
			VALUES (old.l_id, old.isbn, old.languages, old.time_add_to_main, CURRENT_DATE, 'UPDATE');
         END IF;
         RETURN NEW;
END;
$add_time_5$ LANGUAGE plpgsql;


CREATE TRIGGER languages_war AFTER UPDATE OR DELETE on languages
 	FOR EACH ROW EXECUTE FUNCTION add_time_5();

--trigger for time_add_to_main in subscriber
CREATE FUNCTION add_time_6() RETURNS trigger AS $add_time_6$
BEGIN 
         IF (TG_OP = 'DELETE') THEN
            INSERT INTO subscriber_history(membership_number, sub_name, sub_address, sub_birth, membership_Date,
										  sub_mail, sub_phone, time_add_to_main, time_add_to_hist, reason)
			VALUES (old.membership_number, old.sub_name, old.sub_address, old.sub_birth, old.membership_Date,
					old.sub_mail, old.sub_phone, old.time_add_to_main, CURRENT_DATE, 'DELETE');
		 ELSEIF (TG_OP = 'UPDATE') THEN
		 	INSERT INTO subscriber_history(membership_number, sub_name, sub_address, sub_birth, membership_Date,
										  sub_mail, sub_phone, time_add_to_main, time_add_to_hist, reason)
			VALUES (old.membership_number, old.sub_name, old.sub_address, old.sub_birth, old.membership_Date,
					old.sub_mail, old.sub_phone, old.time_add_to_main, CURRENT_DATE, 'UPDATE');
         END IF;
         RETURN NEW;
END;
$add_time_6$ LANGUAGE plpgsql;


CREATE TRIGGER subscriber_war AFTER UPDATE OR DELETE on subscriber
 	FOR EACH ROW EXECUTE FUNCTION add_time_6();


--trigger for time_add_to_main in translator
CREATE FUNCTION add_time_7() RETURNS trigger AS $add_time_7$
BEGIN 
         IF (TG_OP = 'DELETE') THEN
            INSERT INTO translator_history(t_id, isbn, translator, time_add_to_main, time_add_to_hist, reason)
			VALUES (old.t_id, old.isbn, old.translator, old.time_add_to_main, CURRENT_DATE, 'DELETE');
		 ELSEIF (TG_OP = 'UPDATE') THEN
		 	INSERT INTO translator_history(t_id, isbn, translator, time_add_to_main, time_add_to_hist, reason)
			VALUES (old.t_id, old.isbn, old.translator, old.time_add_to_main, CURRENT_DATE, 'UPDATE');
         END IF;
         RETURN NEW;
END;
$add_time_7$ LANGUAGE plpgsql;


CREATE TRIGGER translator_war AFTER UPDATE OR DELETE on translator
 	FOR EACH ROW EXECUTE FUNCTION add_time_7();


--trigger for time_add_to_main in writer
CREATE FUNCTION add_time_8() RETURNS trigger AS $add_time_8$
BEGIN 
         IF (TG_OP = 'DELETE') THEN
            INSERT INTO writer_history(w_id, isbn, writer_name, time_add_to_main, time_add_to_hist, reason)
			VALUES (old.w_id, old.isbn, old.writer_name, old.time_add_to_main, CURRENT_DATE, 'DELETE');
		 ELSEIF (TG_OP = 'UPDATE') THEN
		 	INSERT INTO writer_history(w_id, isbn, writer_name, time_add_to_main, time_add_to_hist, reason)
			VALUES (old.w_id, old.isbn, old.writer_name, old.time_add_to_main, CURRENT_DATE, 'UPDATE');
         END IF;
         RETURN NEW;
END;
$add_time_8$ LANGUAGE plpgsql;


CREATE TRIGGER writer_war AFTER UPDATE OR DELETE on writer
 	FOR EACH ROW EXECUTE FUNCTION add_time_8();
	


	


