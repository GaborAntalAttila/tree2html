@if (@CodeSection == @Batch) @then
@echo off & setlocal

cscript /nologo /e:JScript "%~f0" "%~1"

goto :EOF
@end

var fso = WSH.CreateObject('Scripting.FileSystemObject'),
    htmlfile = WSH.CreateObject('htmlfile'),
    JSON = tree = Array = {},
    path = WSH.Arguments(0) || '.';

htmlfile.write('<meta http-equiv="x-ua-compatible" content="IE=9" />');
JSON = htmlfile.parentWindow.JSON;
Array = htmlfile.parentWindow.Array;
htmlfile.close();

function recurse(path) {
	var dir = fso.GetFolder(path),
        contents = new Array();

    for (var fc = new Enumerator(dir.SubFolders); !fc.atEnd(); fc.moveNext()) {
        contents.push(recurse(fc.item()));
    }

    for (var fc = new Enumerator(dir.Files); !fc.atEnd(); fc.moveNext()){
        if(fso.GetFileName(fc.item()) != "tree2html.bat"){
            contents.push({name: fso.GetFileName(fc.item()), file:"file", path: fc.item()});
        }
    }

	var obj = {};
    obj[dir] = 0;
	var result;
    for (var key in obj)
		result = key;
	var ss;
	  ss = result.split("\\");
	
	var name2;
	for (var key in ss)
		name2 = key;
		
	return {name: ss[name2], children: contents, path: result };
}

tree = recurse(path);

// Generate the html variable that holds the entire web page
var site = "<!DOCTYPE html>\n<html>\n<head>\n  <link href=\"https://fonts.googleapis.com/css?family=Roboto:100,300,400,500,700,900\" rel=\"stylesheet\">\n  <link href=\"https://cdn.jsdelivr.net/npm/@mdi/font@5.x/css/materialdesignicons.min.css\" rel=\"stylesheet\">\n  <link href=\"https://cdn.jsdelivr.net/npm/vuetify@2.x/dist/vuetify.min.css\" rel=\"stylesheet\">\n  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no, minimal-ui\">\n</head>\n<body>\n  <div id=\"app\">\n    <v-app>\n      <v-main>\n        <v-container>\n          <v-sheet class=\"pa-4 primary\">\n            <v-text-field\n              v-model=\"search\"\n              label=\"Search File or Directory\"\n              dark\n              flat\n              solo-inverted\n              hide-details\n              clearable\n              clear-icon=\"mdi-close-circle-outline\"\n            ></v-text-field>\n            <v-row>\n              <v-checkbox\n                v-model=\"caseSensitive\"\n                dark\n                hide-details\n                label=\"Case sensitive search\"\n              ></v-checkbox>\n              <v-checkbox\n                v-model=\"selectable\"\n                dark\n                hide-details\n                label=\"Selectable\"\n                class=\"pl-3\"\n              ></v-checkbox>\n            </v-row>\n          </v-sheet>\n          <v-treeview \n            v-model=\"tree\"\n            activatable \n            :items=\"items\"\n            item-key=\"name\"\n            open-on-click\n            color=\"primary\"\n            :selectable=\"selectable\"\n            :search=\"search\"\n            :filter=\"filter\"\n          >\n          <template v-slot:prepend=\"{ item, open }\">\n            <v-icon v-if=\"!item.file\">\n              {{ open ? 'mdi-folder-open' : 'mdi-folder' }}\n            </v-icon>\n            <v-icon v-else>\n              {{ getFileType(item.name) }}\n            </v-icon>\n          </template>\n          <template v-slot:append=\"{ item, open }\">\n            <v-icon @click=\"openPath(item)\">mdi-content-copy</v-icon>\n          </template>\n          </v-treeview>\n        </v-container>\n        <v-snackbar\n          v-model=\"snackbar\"\n          :timeout=\"snackbarTimeout\"\n          :color=\"snackbarColor\"\n          right \n          top\n        >\n          {{ snackbarMessage }}\n          <template v-slot:action=\"{ attrs }\">\n            <v-btn\n              dark\n              text\n              v-bind=\"attrs\"\n              @click=\"snackbar = false\"\n            >\n              Close\n            </v-btn>\n          </template>\n        </v-snackbar>\n      </v-main>\n    </v-app>\n  </div>\n  <script src=\"https://cdn.jsdelivr.net/npm/vue@2.x/dist/vue.js\"></script>\n  <script src=\"https://cdn.jsdelivr.net/npm/vuetify@2.x/dist/vuetify.js\"></script>\n  <script>\n    new Vue({\n      el: \"#app\",\n      vuetify: new Vuetify(),\n      data() {\n        return {\n          data: {},\n          files: {\n            html: \"mdi-language-html5\",\n            js: \"mdi-nodejs\",\n            json: \"mdi-code-json\",\n            md: \"mdi-language-markdown\",\n            pdf: \"mdi-file-pdf\",\n            png: \"mdi-file-image\",\n            jpg: \"mdi-file-image\",\n            jpeg: \"mdi-file-image\",\n            txt: \"mdi-file-document-outline\",\n            xls: \"mdi-file-excel\",\n            xlsx: \"mdi-file-excel\",\n            ppt: \"mdi-microsoft-powerpoint\",\n            pptx: \"mdi-microsoft-powerpoint\",\n            doc: \"mdi-microsoft-word\",\n            docx: \"mdi-microsoft-word\",\n            '7z': \"mdi-zip-box\",\n            rar: \"mdi-zip-box\",\n            log: \"mdi-math-log\",\n            sql: \"mdi-database\",\n            db: \"mdi-database\",\n            ini: \"mdi-cog-outline\",\n            model: \"mdi-layers\",\n            jt: \"mdi-cube-outline\",\n            file: \"mdi-file\",\n          },\n          tree: [],\n          items: [],\n          search: null,\n          selectable: false,\n          caseSensitive: false,\n          snackbar: false,\n          snackbarMessage: null,\n          snackbarTimeout: 2000,\n          snackbarColor: 'success'\n        };\n      },\n      computed: {\n        filter () {\n          return this.caseSensitive\n            ? (item, search, textKey) => item[textKey].indexOf(search) > -1\n            : undefined\n        },\n      },\n      async mounted() {";
site = site + 'this.items=[' + JSON.stringify(tree, null, '\t') + '];';
site = site + "},\n      methods: {\n        openPath(path) {\n          navigator.clipboard.writeText(path).then(\n            () => {\n              console.log(path)\n              this.snackbarMessage = \"Copied to clipboard! (\"+ path + \")\";\n              this.snackbarColor = \"success\";\n              this.snackbar = true;\n            },\n            (err) =>{\n              this.snackbarMessage = \"Async: Could not copy text: \" + err;\n              this.snackbarColor = \"error\";\n              this.snackbar = true;\n            }\n          );\n        },\n        getFileType(name){\n          let type = name.split(\".\")[1].toLowerCase();\n          let ret = this.files['file']\n          if(type in this.files){\n            ret = this.files[type]\n          }\n          return ret\n        }\n      },\n    });\n  </script>\n</body>\n</html>";
// Instantiate a File System ActiveX Object:
var fso = new ActiveXObject("Scripting.FileSystemObject");
// Invoke the method:
var a = fso.CreateTextFile("index.html", true);
// Do something with it:
a.WriteLine(site);
// Close the connection:
a.Close();