using App.Models;
using App.Models.ListCart;
using App.Models.Product;

namespace AppMvc.Areas.Product.Models 
{
    public class CartItem 
    {
        public int quantity {set; get;}
        public ProductModel product {set; get;}
    }
}