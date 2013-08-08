Package.describe({
   summary: 'Spomet is an example package to provide fulltext search' 
});

Package.on_use(function (api) {
   api.use('coffeescript',['client','server']);
   api.use(['templating'], 'client');
   
   api.add_files('namespace.coffee',['server','client']);
   
   api.add_files('provide_session_id.coffee',['server','client']);
   
   api.add_files('shared.coffee',['server','client']);
   
   api.add_files('server_collections.coffee','server');
   api.add_files('shared_collections.coffee',['server','client']);
   
   api.add_files('server.coffee','server');
   
   api.add_files('search_field.html','client');
   api.add_files('client.coffee','client');
   
   api.add_files('indexes/shared.coffee','server');
   api.add_files('indexes/threegram.coffee','server');
   api.add_files('indexes/fullwords.coffee','server');
   api.add_files('indexes/wordgroup.coffee','server');
});