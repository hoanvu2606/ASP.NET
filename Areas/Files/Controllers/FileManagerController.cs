using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using App.Data;
using elFinder.NetCore;
using elFinder.NetCore.Drivers.FileSystem;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http.Extensions;
using Microsoft.AspNetCore.Mvc;

namespace AppMvc.Areas.Files.Controllers
{
    [Area("Files")]
    [Authorize(Roles = RoleName.Administrator + "," + RoleName.Editor)]
    public class FileManagerController : Controller
    {
        [Route("/file-manager")]
        public IActionResult Index()
        {
            return View();
        }

        IWebHostEnvironment _env;
        public FileManagerController(IWebHostEnvironment env) => _env = env;

    
        [Route("/file-manager-connector")]
        public async Task<IActionResult> Connector()
        {
            var connector = GetConnector();
            return await connector.ProcessAsync(Request);
        }


        [Route("/file-manager-thumb/{hash}")]
        public async Task<IActionResult> Thumbs(string hash)
        {
            var connector = GetConnector();
            return await connector.GetThumbnailAsync(HttpContext.Request, HttpContext.Response, hash);
        }

        private Connector GetConnector()
        {
            string pathroot = "Uploads";
            string requestUrl = "contents";

            var driver = new FileSystemDriver();

            string absoluteUrl = UriHelper.BuildAbsolute(Request.Scheme, Request.Host);
            var uri = new Uri(absoluteUrl);

            string rootDirectory = Path.Combine(_env.ContentRootPath, pathroot);

            string url = $"{uri.Scheme}://{uri.Authority}/{requestUrl}/";

            string urlthumb = $"{uri.Scheme}://{uri.Authority}/file-manager-thumb/";



            var root = new RootVolume( rootDirectory, url, urlthumb)
            {
                IsReadOnly = false, 
                IsLocked = false, 
                Alias = "Thư mục ứng dụng", 
                ThumbnailSize = 100,
            };


            driver.AddRoot(root);

            return new Connector(driver)
            {
                MimeDetect = MimeDetectOption.Internal
            };
        }


    }
}