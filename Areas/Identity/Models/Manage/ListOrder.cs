
// using System.Collections.Generic;
// using System.ComponentModel.DataAnnotations;
// using System.ComponentModel.DataAnnotations.Schema;
// using App.Models.ListCart;
// using Microsoft.AspNetCore.Authentication;
// using Microsoft.AspNetCore.Identity;

// namespace App.Areas.Identity.Models.ManageViewModels
// {
//     public class ListOrder
//     {
//         [Key]
//         public int OrderId { get; set; }
        
//         public int CartId{get; set; }
//         [ForeignKey("CartId")]
//         [Display(Name = "CartId")]
//         public List<CartDB> cartDBs { get; set; }

//         [Required]
//         [Display(Name = "Trạng thái")]
//         public int OrderStatus { get; set; }


//     }
// }
