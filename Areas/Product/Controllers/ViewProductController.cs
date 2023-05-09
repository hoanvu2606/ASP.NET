using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using App.Models;
using App.Models.ListCart;
using App.Models.Product;
using AppMvc.Areas.Product.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace AppMvc.Net.Areas.Product.Controllers
{
    [Area("Product")]
    public class ViewProductController : Controller
    {
        private readonly ILogger<ViewProductController> _logger;
        private readonly AppDbContext _context;

        private readonly CartService _cartService;

        private readonly UserManager<AppUser> _userManager;


        public ViewProductController(ILogger<ViewProductController> logger, AppDbContext context, CartService cartService,UserManager<AppUser> userManager)
        {
            _logger = logger;
            _context = context;
            _cartService = cartService;
            _userManager = userManager;
        }

        [TempData]
        public string StatusMessage {set; get;}

        // /post/
        // /post/{categoryslug?}
        [Route("/product/{categoryslug?}")]
        public IActionResult Index(string categoryslug, [FromQuery(Name = "p")]int currentPage, int pagesize,IFormCollection? form,string? filter)
        {
            var categories = GetCategories();

            ViewBag.categories = categories;
            ViewBag.categoryslug = categoryslug;

            CategoryProduct category = null;

            if (!string.IsNullOrEmpty(categoryslug))    
            {
                category = _context.CategoryProducts.Where(c => c.Slug == categoryslug)
                                    .Include(c => c.CategoryChildren)
                                    .FirstOrDefault();

                if (category == null)
                {
                    return NotFound("Không thấy category");
                }                    
            }

            var products = _context.Products
                                .Include(p => p.Author)
                                .Include(p => p.Photos)
                                .Include(p => p.ProductCategoryProducts)
                                .ThenInclude(p => p.Category)
                                .AsQueryable();
            
            products = products.OrderByDescending(p => p.DateUpdated);

            var countsp=0;
            if( !string.IsNullOrEmpty(form["searchblog"]))
            { 

                if(products.Where(x=>x.Title.Contains(form["searchblog"])).Any())
                {

                countsp += products.Count(p =>p.Title.Contains(form["searchblog"]));

                products = products.Where(x=>x.Title.Contains(form["searchblog"]));

                ViewData["find"] ="yes";

                    
                }
                else{
                products = products.OrderByDescending(p => p.DateUpdated);

                }
                ViewData["countsp"] = countsp;
                
            }
            else{
                ViewData["find"] ="no";
            }
            

            if(!string.IsNullOrEmpty(filter))
            {
                if(filter=="1")
                {
                products = products.OrderByDescending(p => p.DateUpdated);

                }
                if(filter=="2")
                {
                products = products.OrderBy(p => p.DateUpdated);

                }
                if(filter=="3")
                {
                products = products.OrderBy(p => p.Price);

                }
                if(filter=="4")
                {
                products = products.OrderByDescending(p => p.Price);

                }
            }
            else{
            products = products.OrderByDescending(p => p.DateUpdated);

            }


            if (category != null)
            {
                var ids = new List<int>();
                category.ChildCategoryIDs(null, ids);
                ids.Add(category.Id);


                products = products.Where(p => p.ProductCategoryProducts.Where(pc => ids.Contains(pc.CategoryID)).Any());


            }

            int totalProducts = products.Count();  
            if (pagesize <=0) pagesize = 10;
            int countPages = (int)Math.Ceiling((double)totalProducts / pagesize);
 
            if (currentPage > countPages) currentPage = countPages;     
            if (currentPage < 1) currentPage = 1; 

            var pagingModel = new PagingModel()
            {
                countpages = countPages,
                currentpage = currentPage,
                generateUrl = (pageNumber) => Url.Action("Index", new {
                    p =  pageNumber,
                    pagesize = pagesize
                })
            };

            var productsInPage = products.Skip((currentPage - 1) * pagesize)
                             .Take(pagesize);   


            ViewBag.pagingModel = pagingModel;
            ViewBag.totalPosts = totalProducts; 


                 
            ViewBag.category = category;
            return View(productsInPage.ToList());
        }

        [Route("/product/{productslug}.html")]
        public IActionResult Detail(string productslug)
        {
            var categories = GetCategories();
            ViewBag.categories = categories;

            var product = _context.Products.Where(p => p.Slug == productslug)
                               .Include(p => p.Author)
                               .Include(p => p.Photos)
                               .Include(p => p.ProductCategoryProducts)
                               .ThenInclude(pc => pc.Category)
                               .Include(p =>p.ReviewList)
                               .FirstOrDefault();

            if (product == null)
            {
                return NotFound("Không thấy bài viết");
            }            

            CategoryProduct category = product.ProductCategoryProducts.FirstOrDefault()?.Category;
            ViewBag.category = category;

            var otherProducts = _context.Products.Where(p => p.ProductCategoryProducts.Any(c => c.Category.Id == category.Id))
                                            .Where(p => p.ProductID != product.ProductID)
                                            .OrderByDescending(p => p.DateUpdated)
                                            .Take(5);
            ViewBag.otherProducts = otherProducts;                                

            return View(product);
        }

        private List<CategoryProduct> GetCategories()
        {
            var categories = _context.CategoryProducts
                            .Include(c => c.CategoryChildren)
                            .AsEnumerable()
                            .Where(c => c.ParentCategory == null)
                            .ToList();
            return categories;                
        }


        [Route ("addcart/{productid:int}", Name = "addcart")]
        public IActionResult AddToCart ([FromRoute] int productid) {

            var product = _context.Products
                .Where (p => p.ProductID == productid)
                .FirstOrDefault ();
            if (product == null)
                return NotFound ("Không có sản phẩm");

            var cart = _cartService.GetCartItems();
            var cartitem = cart.Find (p => p.product.ProductID == productid);
            if (cartitem != null) {
                cartitem.quantity++;
            } else {
                cart.Add (new CartItem () { quantity = 1, product = product });
            }

            _cartService.SaveCartSession (cart);
            return RedirectToAction (nameof (Cart));
        }
        [Route ("/cart", Name = "cart")]
        public IActionResult Cart () 
        {
            return View (_cartService.GetCartItems());
        }
        
        [Route ("/removecart/{productid:int}", Name = "removecart")]
        public IActionResult RemoveCart ([FromRoute] int productid) {
            var cart = _cartService.GetCartItems ();
            var cartitem = cart.Find (p => p.product.ProductID == productid);
            if (cartitem != null) {
                cart.Remove(cartitem);
            }

            _cartService.SaveCartSession (cart);
            return RedirectToAction (nameof (Cart));
        }

        [Route ("/updatecart", Name = "updatecart")]
        [HttpPost]
        public IActionResult UpdateCart ([FromForm] int productid, [FromForm] int quantity) {
            StatusMessage=null;
            var cart = _cartService.GetCartItems ();
            var cartitem = cart.Find (p => p.product.ProductID == productid);
            if(quantity>cartitem.product.quantity)
            {
                StatusMessage=$"Số lượng sản phẩm {cartitem.product.Title} không đủ";
            }
            else
            {
                if (cartitem != null) {
                cartitem.quantity = quantity;
                }
                _cartService.SaveCartSession (cart);
            StatusMessage=null;

            }
            
            

            
            
            return Ok();
        }

        

        [Route ("/checkout")]
        public async Task<IActionResult> Checkout(IFormCollection form,[FromForm] int productid, CartDB cartdb)
        {
            var cart = _cartService.GetCartItems ();
            var cartitem = cart.Find (p => p.product.ProductID == productid);

            // ....
            var userr = await _userManager.GetUserAsync(this.User);
            var content = "";
            decimal total = 0;
            foreach (var item in cart)
            {
                content += item.product.Title + " x " + item.quantity + "  ";
                total += item.quantity * item.product.Price;
                item.product.quantity -= item.quantity;
                _context.Products.Update(item.product);
            }
            

            cartdb.UserId = userr.Id;
            cartdb.CartUserName = form["Name"];
            cartdb.Content = content;
            cartdb.PhoneNumber = form["PhoneNumber"];
            cartdb.Address = form["Address"];
            cartdb.CartTotal = total;
            cartdb.DateCreated = DateTime.Now;
            // cartdb.CartUserName = userr.UserName;
            _context.Add(cartdb);




            _cartService.ClearCart();
            
            await _context.SaveChangesAsync();

            // return Content("Da gui don hang");
            StatusMessage = "Đơn hàng của bạn đã được gửi";

            return RedirectToAction("Index", "Home");

        }

        [Route (template: "/addreview/{productid?}")]
        [HttpGet]
        public async Task<IActionResult> AddReview(int productid)
        {
            return View();
        }

        [Route (template: "/addreview/{productid?}")]
        [Authorize]
        [HttpPost]
        public async Task<IActionResult> AddReview([Bind("reviewName,start,content")] Review reviews,int productid)
        {
            var product = await _context.Products.FirstOrDefaultAsync(p => p.ProductID == productid);
            if (product == null) return NotFound("Không tìm thấy san pham");
            if (ModelState.IsValid){

            reviews.ProductID = product.ProductID;

            _context.Add(reviews);
            await _context.SaveChangesAsync();

            StatusMessage = "Thêm review thành công.";
                        
            return RedirectToAction("Detail", new {productslug = product.Slug});
            }

           return View();
        }
        
        [HttpGet("/admin/orders/detail/{id}")]
        public async Task<IActionResult> OrderDetailAdmin(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }




            var order = await _context.CartDBs
                .FirstOrDefaultAsync(m => m.CartId == id);
            if (order == null)
            {
                return NotFound();
            }

            return View(order);
        }

    }
}