create database MyTest;
use MyTest;

create table category (
	id int auto_increment primary key,
    name varchar(100) not null,
    status tinyint default 1 check(status = 0 or status = 1)
);

create table author (
	id int auto_increment primary key,
    name varchar(100) not null unique,
    total_book int default 0 
);

create table book (
	id int auto_increment primary key,
    name varchar(150) not null unique,
    status tinyint default 1 check(status = 0 or status = 1),
    price float not null check(price > 100000) unique,
    createDate date default(now()) ,
    category_id int not null,
    author_id int not null,
    foreign key(category_id) references category(id),
    foreign key(author_id) references author(id)
);

create table customer (
	id int auto_increment primary key,
    name varchar(150) not null,
    email varchar(150) not null unique,
    phone varchar(50) not null unique,
    address varchar(255),
    createDate date default(now()),
    gender tinyint not null check(gender = 0 or gender = 1 or gender = 2),
	birthday date not null
);


create table ticket (
	id int auto_increment primary key,
    customer_id int not null,
    status tinyint default 1 check(status = 0 or status = 1 or status = 2),
    ticket_date date,
    foreign key(customer_id) references customer(id)
);

create table ticketDetail (
	ticket_id int not null,
    book_id int not null,
    quantity int not null check(quantity > 0),
    deposiPrice double not null,
    rentCost double not null,
    primary key(ticket_id,book_id),
    foreign key(ticket_id) references ticket(id),
    foreign key(book_id) references book(id)
);

set delimiter //
create trigger before_insert_customer
before insert on customer for each row
begin
	if (NEW.createDate < curdate()) then
		signal sqlstate '45000' set message_text = 'error insert date';
    end if;
end;

-- insert data
-- category 
INSERT INTO category (name, status) VALUES
('Fiction', 1),
('Science', 1),
('History', 1),
('Romance', 1),
('Mystery', 1);

-- author 
INSERT INTO author (name, total_book) VALUES
('John Doe', 10),
('Jane Smith', 5),
('Michael Johnson', 8),
('Emily Brown', 3),
('Robert Lee', 12);

-- book
INSERT INTO book (name, status, price, createDate, category_id, author_id) VALUES
('Book A', 1, 150000, '2023-07-01', 1, 1),
('Book B', 1, 180000, '2023-07-02', 2, 1),
('Book C', 0, 120000, '2023-07-03', 3, 2),
('Book D', 1, 135000, '2023-07-04', 2, 3),
('Book E', 1, 200000, '2023-07-05', 4, 4),
('Book F', 1, 210000, '2023-07-06', 5, 5),
('Book G', 1, 165000, '2023-07-07', 1, 3),
('Book H', 1, 176000, '2023-07-08', 2, 4),
('Book I', 1, 145000, '2023-07-09', 3, 5),
('Book J', 0, 130000, '2023-07-10', 4, 2),
('Book K', 1, 190000, '2023-07-11', 5, 1),
('Book L', 1, 220000, '2023-07-12', 1, 5),
('Book M', 1, 155000, '2023-07-13', 2, 4),
('Book N', 1, 175000, '2023-07-14', 3, 3),
('Book O', 1, 185000, '2023-07-15', 4, 2);

-- customer
INSERT INTO customer (name, email, phone, address, createDate, gender, birthday) VALUES
('Alice Johnson', 'alice@example.com', '123456789', '123 Main St, City', '2023-07-30', 1, '1990-05-15'),
('Bob Smith', 'bob@example.com', '987654321', '456 Oak St, Town', '2023-07-30', 0, '1985-08-25'),
('Eve Brown', 'eve@example.com', '456789123', '789 Elm St, Village', '2023-07-30', 2, '1995-03-10');

-- ticket and ticketDetail
INSERT INTO ticket (customer_id, status, ticket_date) VALUES (1, 1, '2023-07-19');

INSERT INTO ticketDetail (ticket_id, book_id, quantity, deposiPrice, rentCost) VALUES
(1, 1, 1, 50000, 20000), 
(1, 3, 2, 80000, 30000); 

INSERT INTO ticket (customer_id, status, ticket_date) VALUES (2, 2, '2023-07-20');

INSERT INTO ticketDetail (ticket_id, book_id, quantity, deposiPrice, rentCost) VALUES
(2, 2, 1, 60000, 25000),
(2, 5, 2, 100000, 40000), 
(2, 7, 1, 60000, 25000); 

INSERT INTO ticket (customer_id, status, ticket_date) VALUES (3, 0, '2023-07-21');

INSERT INTO ticketDetail (ticket_id, book_id, quantity, deposiPrice, rentCost) VALUES
(3, 9, 1, 70000, 28000), 
(3, 12, 1, 75000, 32000); 
