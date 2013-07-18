Package.describe({
   summary: 'Spomet is an example package to provide fulltext search' 
});

Package.on_use(function (api) {
   api.use('coffeescript',['client','server']);
   api.add_files('server_collections.coffee','server');
   api.add_files('shared_collections.coffee',['server','client']);
   
   api.add_files('index.coffee','server');
   api.add_files('client.coffee','client');
   api.add_files('search_field.html','client');
   
});