Package.describe({
   summary: 'Spomet is an example package to provide fulltext search' 
});

Package.on_use(function (api) {
   api.use('coffeescript',['client','server']);
   api.use('templating', 'client');
   
   api.add_files('md5.js', ['server']);
   api.add_files('provide_session_id.coffee',['server','client']);
   
   api.add_files('indexes/threegram.coffee','server');
   api.add_files('indexes/fullword.coffee','server');
   api.add_files('indexes/wordgroup.coffee','server');
   
   api.add_files('indexes/documents.coffee','server')
   api.add_files('indexes/index.coffee','server');
   
   api.add_files('shared.coffee',['server','client']);
   
   api.add_files('server.coffee','server');
   
   api.add_files('search_field.html','client');
   api.add_files('client.coffee','client');
   
   api.export('Spomet',['server','client']);
   
   api.export('ThreeGramIndex','server',{testOnly: true})
   api.export('FullWordIndex','server',{testOnly: true})
   api.export('WordGroupIndex','server',{testOnly: true})
   });