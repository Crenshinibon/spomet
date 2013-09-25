Package.describe({
   summary: 'Spomet is an example package to provide fulltext search' 
});

Package.on_use(function (api) {
   api.use('standard-app-packages', ['client', 'server']);
   api.use('coffeescript',['client','server']);
   
   api.add_files('md5.js', ['client','server']);
   
   api.add_files('img/ajax-loader.gif','client');
   api.add_files('img/styles.css','client');
   
   api.add_files('shared.coffee',['server','client']);
  
   api.add_files('indexes/threegram.coffee','server');
   api.add_files('indexes/custom.coffee','server');
   api.add_files('indexes/fullword.coffee',['server','client']);
   api.add_files('indexes/wordgroup.coffee','server');
   
   api.add_files('indexes/documents.coffee',['client','server'])
   api.add_files('indexes/index.coffee','server');
   
   api.add_files('server.coffee','server');
   
   api.add_files('client.coffee','client');
   api.add_files('search_field.html','client');
   api.add_files('search_field.coffee','client');
   
   api.export('Spomet',['server','client']);
});