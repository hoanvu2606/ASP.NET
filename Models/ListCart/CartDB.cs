using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace App.Models.ListCart {
    [Table("CartDB")]
    public class CartDB
    {
            [Key]
            public int CartId {set; get;}

            public string UserId {set; get;}
            [ForeignKey("UserId")]
            [Display(Name = "Id KH")]
            public AppUser cartuser {set; get;}

            [Required]
            [Display(Name = "Sản phẩm")]
            public string Content {set; get;}


            [Display(Name = "Tên người nhận")]
            public string CartUserName { set; get; }

            [Required]
            [Phone]
            [Display(Name = "Số điện thoại")]
            public string PhoneNumber { get; set; }
            
            [Required]
            [Display(Name = "Địa chỉ")]
            public string Address { get; set; }

            [Required]
            [Display(Name = "Tổng tiền")]
            public decimal CartTotal { get; set; }

            [Display(Name = "Ngày đặt")]
            public DateTime DateCreated {set; get;}
            
            [Display(Name = "Trạng thái")]
            public string Status { get; set; }
    }
}