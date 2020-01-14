const debugMode = location.hostname == "localhost";

window["global"] = () => top;
var root = document.documentElement;
top.appLocation = window.location;
top.topWindow = window;
console.log(`debugMode: ${debugMode}`);

document.addEventListener("contextmenu", event => event.preventDefault());

if (debugMode) {
  window["_ver"] = Date.now();

  top["setLocationHash"] = (hash) => {
    //Silent
  }

  window["setSize"] = () => {
    //Silent
  }

  document.write(`
    <script src="main.dart.js?_ver=${_ver}"> 
    <\/script>
  `);
} else {
  window["_ver"] = parseInt("«ver»");

  top["setLocationHash"] = (hash) => {
    location.hash = hash;
  }

  window["setLocationHash"] =  top["setLocationHash"] ;
  
  window["setSize"] = () => {
    const app = document.getElementById("app");
    app.style.setProperty("width", `${window.innerWidth}px`);
    app.style.setProperty("height", `${window.innerHeight}px`);
  }

  // window.addEventListener("popstate", function(event) {
  //   history.pushState(null, document.title, location.href);
  // });

  window.addEventListener("resize", (event) => {
    window.setSize();
  });

  let route = location.hash.substring(2).replace(/\//g, "\\");

  if (route == "") {
    route = "/";
  }

  console.log(`initial route: ${route}`);

  window.addEventListener("hashchange", () => {
    if (window.location.hash.split("?")[0] != top.appLocation.hash.split("?")[0]) {
      const hash =
        "/" + window.location.hash.substring(2).replace(/\//g, "\\");
      //console.log(`top hash: ${hash}`);
      top.appLocation.hash = hash;
    }
  });

  document.write(`
    <iframe id="app" src="frame.html?_ver=«ver»&_time=${Date.now()}#${route}">
    <\/iframe>
  `);
}
