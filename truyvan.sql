-- Yêu cầu 1 ( Sử dụng lệnh SQL để truy vấn cơ bản ): 
-- •	Lấy ra danh sách Book có sắp xếp giảm dần theo Price gồm các cột sau: Id, Name, Price, Status, CategoryName, AuthorName, CreatedDate
	select b.id,b.name,b.price,b.status,c.name,a.name,b.createDate from book b
    join category c on b.category_id = c.id
    join author a on a.id = b.author_id
    order by price desc;
    
-- •	Lấy ra danh sách Category gồm: Id, Name, TotalProduct, Status (Trong đó cột Status nếu = 0, Ẩn, = 1 là Hiển thị )
	select c.name,count(b.id),
    case 
		when c.status = 1 then 'Hiển thị'
		when c.status = 0 then 'Ẩn'
    end as 'trạng thái' from category c
    join book b on c.id = b.category_id 
    group by c.id;
    
-- •	Truy vấn danh sách Customer gồm: Id, Name, Email, Phone, Address, CreatedDate, Gender, BirthDay, Age (Age là cột suy ra từ BirthDay, Gender nếu = 0 là Nam, 1 là Nữ,2 là khác )
	select id,name,email,phone,address,createDate,
    case 
		when gender = 0 then 'Nam'
		when gender = 1 then 'Nữ'
		when gender = 2 then 'Khác'
    end as gender
    ,birthday,(year(now()) - year(birthday)) age from customer;

-- •	Truy vấn xóa Author chưa có sách nào
delete from author where id not in (select distinct a.id from author a join book b on a.id = b.author_id);

-- •	Cập nhật Cột TotalBook trong bảng Author = Tổng số Book của mỗi Author theo Id của Author
update author as a
join (
	select author_id,count(*) as total from book
    group by author_id
) as b on a.id = b.author_id set a.total_book =  b.total;

-- Yêu cầu 2 ( Sử dụng lệnh SQL tạo View )
-- •	View v_getBookInfo thực hiện lấy ra danh sách các Book được mượn nhiều hơn 3 cuốn 
create view v_getBookInfo as
select * from book b join ticketdetail tkdt on b.id = tkdt.book_id where tkdt.quantity >= 3;

-- •	View v_getTicketList hiển thị danh sách Ticket gồm: Id, TicketDate, Status, CusName, Email, Phone,TotalAmount (Trong đó TotalAmount là tổng giá trị tiện phải trả, cột Status nếu = 0 thì hiển thị Chưa trả, = 1 Đã trả, = 2 Quá hạn, 3 Đã hủy) 
create view v_getTicketList as
select tk.id,tk.ticket_date,tk.status,c.name,c.email,c.phone,sum(tkdt.quantity * tkdt.deposiPrice) from ticket tk 
join customer c on c.id = tk.customer_id 
join ticketdetail tkdt on tk.id = tkdt.ticket_id
group by tk.id;

-- Yêu cầu 3 ( Sử dụng lệnh SQL tạo thủ tục Stored Procedure )
-- •	Thủ tục addBookInfo thực hiện thêm mới Book, khi gọi thủ tục truyền đầy đủ các giá trị của bảng Book ( Trừ cột tự động tăng )

delimiter // 
create procedure addBookInfo(name1 varchar(150),status1 tinyint,price1 float,createDate1 date,category_id1 int,author_id1 int)
begin
	insert into book (name, status, price, createDate, category_id, author_id) values
    (name1,status1,price1,createDate1,category_id1,author_id1);
end //
// 
call addBookInfo("BOOKING",1,111111,"2023/07/29",1,1);
-- •	Thủ tục getTicketByCustomerId hiển thị danh sách đơn hàng của khách hàng theo Id khách hàng gồm: Id, TicketDate, Status, TotalAmount (Trong đó cột Status nếu =0 Chưa trả, = 1  Đã trả, = 2 Quá hạn, 3 đã hủy ), Khi gọi thủ tục truyền vào id cuả khách hàng

delimiter //
create procedure getTicketByCustomerId(id int)
begin
	select tk.id,tk.ticket_date,tk.status,(tkdt.quantity * tkdt.deposiPrice) as total_amount from ticket tk 
    join ticketdetail tkdt on tk.id = tkdt.ticket_id
    where tk.customer_id = id;
end //
//

call getTicketByCustomerId(1);

-- •	Thủ tục getBookPaginate lấy ra danh sách sản phẩm có phân trang gồm: Id, Name, Price, Sale_price, Khi gọi thủ tuc truyền vào limit và page

delimiter //
create procedure getBookPaginate(pageLimit int,page int)
begin
	select id,name,price from book limit pageLimit offset page;
end //	
//
call getBookPaginate(3,1);

-- Yêu cầu 4 ( Sử dụng lệnh SQL tạo Trigger )
-- •	Tạo trigger tr_Check_total_book_author sao cho khi thêm Book nếu Author đang tham chiếu có tổng số sách > 5 thì không cho thêm mưới và thông báo “Tác giả này có số lượng sách đạt tới giới hạn 5 cuốn, vui long chọn tác giả khác” 

set delimiter //
create trigger tr_Check_total_book_author 
before insert on book for each row
begin
	declare sl int;
	select count(*) into sl from book where author_id = NEW.author_id;
    if sl > 5 then
		signal sqlstate '45000' set message_text = 'add false because book quantity full';
    end if;
end;

-- •	Tạo trigger tr_Update_TotalBook khi thêm mới Book thì cập nhật cột TotalBook rong bảng Author = tổng của Book theo AuthorId

set delimiter //
create trigger tr_Update_TotalBook
after insert on book for each row
begin
	update author set total_book = total_book + 1 where id = NEW.author_id;
end;

