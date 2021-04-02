// Package Dependency Check Action
// - Built for utassault.net - github.com/Sizzl
// - Uses the excellent UTReader.js from bunnytrack.net - github.com/bunnytrack

// -- Args and parameters --
var args = process.argv.slice(2)

const mapfilter = 'AS-';
var timeout=300; // seconds

// -- Import modules --

var path = require('path');
var fs = require('fs');
if (!(fs.existsSync('./UTReader.js')) && !(fs.existsSync('./Modules/UTReader.js'))) {
	console.error('Dependency missing: UTReader.js');
	console.log('Aborting due to missing module.');
	process.exit(2);
}
if (fs.existsSync('./Modules/UTReader.js')) {
	var utreader = require('./Modules/UTReader.js');
} else {
	var utreader = require('./UTReader.js');	
}

// -- Initial vars - DO NOT ALTER --
var sources = [];
var missing = [];

var uttextures = [];
var utsounds = [];
var utmusic = [];
var utsystem = [];

var mapcount = -1;
var mapschecked = -1;

// -- Arg checking & source directory checks --

if (args.length > 1) {
	sources = args;
} else {
	if (args.length == 1) {
		var rootdir = args[0];
	}
	else {
		var rootdir = __dirname;
	}
	// root directory, find appropriate children
	if (fs.existsSync(rootdir)) {
		var files = fs.readdirSync(rootdir,{ withFileTypes: true });
		
		files.filter(d => !(d.isFile()) &&  ['music','sounds','system','textures'].indexOf(d.name.toLowerCase()) > -1).forEach(function(item) {
			sources.push(path.join(rootdir,item.name));
		});

		files.filter(d => !(d.isFile()) && ['maps'].indexOf(d.name.toLowerCase()) > -1).forEach(function(item) {
			sources.push(path.join(rootdir,item.name));
		});
	} else {
		console.warn('Input directory not found: '+rootdir);
	}
	if (sources.length == 0) {
		console.error('\x1b[91mNo UnrealTournament files found within the current or provided location: '+rootdir+'\x1b[39m\x1b[0m');
		process.exit(2);
	}
} 

// -- Begin synchronous and asynchronous activities --

console.log('\x1b[32mUT99 Package Dependency Checker\x1b[89m');
console.log('\x1b[0m');

sources.forEach(function (sourcepath) {
	if (fs.existsSync(sourcepath)) {
		fs.readdir(sourcepath , function (err, files) {
			if (err) {
				console.log('\x1b[91m* Unable to scan directory: '+err+'\x1b[39m');
				console.log('\x1b[0m');
				
			} else {
				console.log('\x1b[93m* Scanning directory: '+sourcepath+'\x1b[39m');
				console.log('\x1b[0m');
				// Cache textures, sounds, music, system files where present
				files.filter(f => (path.extname(f).toLowerCase() === '.utx')).forEach(function(item) {
					uttextures.push(path.parse(item).name.toLowerCase());
				});
				files.filter(f => (path.extname(f).toLowerCase() === '.uax')).forEach(function(item) {
					utsounds.push(path.parse(item).name.toLowerCase());
				});
				files.filter(f => (path.extname(f).toLowerCase() === '.umx')).forEach(function(item) {
					utmusic.push(path.parse(item).name.toLowerCase());
				});
				files.filter(f => (path.extname(f).toLowerCase() === '.u')).forEach(function(item) {
					utsystem.push(path.parse(item).name.toLowerCase());
				});

				// Parse maps where present
				const maps = files.filter(f => (path.extname(f).toLowerCase() === '.unr' && f.startsWith(mapfilter)));
				if (maps.length) {
					mapcount = maps.length;
					mapschecked = 0;
					maps.forEach(function (file) {
						fs.readFile(path.join(sourcepath,file), function (err, data) {
							if (timeout < 0)
								return;
							console.log('\x1b[1m'+file+'\x1b[22m');
							if (err) throw err;
							const reader  = new utreader(data.buffer);
							const package = reader.readPackage();
							const depends = package.getDependencies();
							console.log('\x1b[1m  \"'+package.getLevelSummary().Title+'\"\x1b[22m');
							console.log('\x1b[0m');
							let customs = depends.filter(pkg => (pkg.default === false));
							customs.forEach(function(pkg) {
								let package = pkg.name.toLowerCase();
								if (uttextures.indexOf(package) > -1) {
									console.log('- Found Texture Pack: '+uttextures[uttextures.indexOf(package)]);
								} else if (utsounds.indexOf(package) > -1) {
									console.log('- Found Sound Pack: '+utsounds[utsounds.indexOf(package)]);
								} else if (utmusic.indexOf(package) > -1) {
									console.log('- Found Music Package: '+utmusic[utmusic.indexOf(package)]);
								} else if (utsystem.indexOf(package) > -1) {
									console.log('- Found System Package: '+utsystem[utsystem.indexOf(package)]);
								} else {
					            	console.log('- Not found: '+pkg.name.toLowerCase());
					            	if (missing.indexOf(package) < 0) {
					            		missing.push(package);
					            	}
					        	}
							});
							mapschecked++;
							if (customs.length) {
								console.log('\x1b[0m');
							}
						});
					});
				}
			}
		});
	} else {
		console.error('\x1b[91m* Unable to scan directory (not present): ' + sourcepath+'\x1b[39m');
		console.log('\x1b[0m');
	}
});

// -- Start a montitoring thread --
var main = setInterval(function () { 
	if (mapcount > -1) {
		if(mapschecked>=mapcount) {
			if (mapschecked>mapcount) {
				console.log('\x1b[92mAll maps parsed (and more?!)\x1b[39m');
			} else {
				console.log('\x1b[92mAll maps parsed.\x1b[39m');
			}
			console.log('\x1b[0m');
			if (missing.length) {
				console.warn('-- '+missing.length+' missing files --');
				console.warn(missing);
				clearInterval(main);
				process.exit(2);
			} else {
				console.log('\x1b[92mAll files present and accounted for.\x1b[39m');
				console.log('\x1b[0m');
			    clearInterval(main);
			    process.exit(0);
			}
		} else {
			console.log('\x1b[96m** '+mapschecked+'/'+mapcount+' maps parsed...\x1b[39m');
			console.log('\x1b[0m');
		}
	} else {
		console.warn('No maps parsed yet...');
	}
	timeout--;
	if (timeout < 0) {
		console.error('\x1b[91mAborting due to timeout exceeding defined value.\x1b[39m');
		console.error('\x1b[0m');
		clearInterval(main);
		process.exit(1);
	}
}, 1000);

