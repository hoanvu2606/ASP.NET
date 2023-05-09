using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using App.Models;
using App.Models.ListCart;
using App.Models.Product;

namespace AppMvc.Areas.Product.Models 
{
    public class Review 
    {   
        [Key]
        public int ReviewId { get; set; }

        public int ProductID {set; get;}
        [ForeignKey("ProductID")]
        public ProductModel ProductModel {set; get;}

        [Required]
        [Display(Name ="Họ Tên")]
        public string reviewName {set; get;}

        [Required]
        [Display(Name ="Số sao")]
        [Range(1,5)]
        public int start { get; set; }

        [Required]
        [Display(Name ="Nhận xét")]
        public string content {set; get;}
    }
}