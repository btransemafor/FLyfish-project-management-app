# Tên Dự Án: **FlyFish – Project Management App**

**FlyFish – Project Management App** – Ứng dụng di động giúp quản lý dự án, trong mỗi dự án sẽ có nhiều nhiệm vụ, có thể thêm các thành viên vào dự án, phân công nhiệm vụ cho thành viên. 

---


## Tổng quan

* Backend: **Node.js + PostgreSQL**, tối ưu truy vấn bằng **indexing**, cung cấp **RESTful API**.
* Frontend: **Flutter** theo **Clean Architecture**, **Bloc** state management, **goRouter** điều hướng.
* Realtime: Bình luận & thông báo **thời gian thực** bằng **Socket.IO + Streams**.
* UI: Widget tối ưu, trải nghiệm mượt, dữ liệu động hiển thị trực quan.

---

##  Điểm nổi bật

* Quản lý dữ liệu hiệu quả, API REST.
* State management với Bloc.
* Kiến trúc modular, dễ mở rộng, maintainable.
* Realtime notifications & comments 
* Database indexing cải thiện tốc độ truy vấn.
* Giao diện thân thiện
* Quản lý phiên với token: 
  * access Token để gửi kèm khi yêu cầu truy cập vào các tài nguyên có thời gian time to live ngắn hơn so hơn refresh token, 
  * Refresh token giúp người dùng vẫn duy trì trang thái login trong thời gian dài 

---

### Tech Stack

* **Backend:** Node.js, PostgreSQL, Model Sequelize
* **Frontend:** Flutter, Bloc, goRouter, DIO, getIt
* **Realtime:** Socket.IO, Streams

* **Email Service**: Khi tạo task mới, khi có người bình luận trong task, trạng thái dự án thay đổi, ...

---

Các tính năng quan trọng của app đã hoàn thiện chỉ còn vài phần nhỏ để khiến app trọn vẹn hơn. Tôi sẽ tiếp tục thực hiện nó trong tương lai gần.





### **Demo:** [xem tại đây ( sẽ update thêm trong thời gian tới ... )](https://drive.google.com/drive/folders/11DRP8EEXAJd2KAXHImvNhymffSopR7PK?usp=drive_link)
