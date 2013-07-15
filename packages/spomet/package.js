Package.describe({
   summary: 'Spomet is an example package to provide fulltext search' 
});

Package.on_use(function (api) {
   api.use('coffeescript',['client','server']);
   api.add_files('collections.coffee','server');
   api.add_files('index.coffee',['client','server']);
   api.add_files('search_field.html','client');
});