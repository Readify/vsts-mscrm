var gulp = require('gulp');
var exec = require('child_process').exec;
var minimist = require('minimist');
var semver = require('semver');
var fs = require('fs');
var glob = require('glob');

// Default version data. Should be replaced as soon as the get-version task runs.
var version = {
    "Major": 0,
    "Minor": 0,
    "Patch": 1,
    "MajorMinorPatch": "0.0.1",
};

var args = minimist(process.argv);
var channelsContent = fs.readFileSync('channels.json', 'utf8');
var channels = JSON.parse(channelsContent);

if (args.channel) {
    var channel = channels[args.channel];
} else {
    var channel = channels['default'];
}

console.log('Selected Channel is: ' + channel.id);

gulp.task('get-version', function (callback) {
    if (args.overrideversion && semver.valid(args.overrideversion)) {
        console.log("Using override to get version numbers.");
        version.MajorMinorPatch = args.overrideversion;
        version.Major = semver.major(args.overrideversion);
        version.Minor = semver.minor(args.overrideversion);
        version.Patch = semver.patch(args.overrideversion);
        callback();
    } else if (process.env.GITVERSION_MajorMinorPatch) {
        console.log("Environment variables to get version numbers.");
        version.MajorMinorPatch = process.env.GITVERSION_MajorMinorPatch;
        version.Major = semver.major(process.env.GITVERSION_MajorMinorPatch);
        version.Minor = semver.minor(process.env.GITVERSION_MajorMinorPatch);
        version.Patch = semver.patch(process.env.GITVERSION_MajorMinorPatch);
        callback();
    } else {
        console.log("Running GitVersion to get version numbers.");
        exec('gitversion', function(err, stdout, stderr) { 
            version = JSON.parse(stdout);
            callback(err);
        });
    }
});

function stampTaskJson(path, taskName) {
    var taskDefinitionContents = fs.readFileSync(path, 'utf8');
	var taskDefinition = JSON.parse(taskDefinitionContents);

    var channelTaskSetup = channel.tasks[taskName]

    taskDefinition.id = channelTaskSetup.id;
    taskDefinition.name = channelTaskSetup.name;
    taskDefinition.friendlyName = channelTaskSetup.friendlyName;

	taskDefinition.version = {
        "Major": version.Major,
        "Minor": version.Minor,
        "Patch": version.Patch
    };
    
	taskDefinitionContents = JSON.stringify(taskDefinition, null, '\t');
	fs.writeFileSync(path, taskDefinitionContents);    
}

gulp.task('stamp-manifest', ['get-version'], function (callback) {
    var manifestContents = fs.readFileSync('src\\vss-extension.json', 'utf8');
	var manifest = JSON.parse(manifestContents);

    manifest.id = channel.id;
    manifest.name = channel.name;
	manifest.version = version.MajorMinorPatch;

	manifestContents = JSON.stringify(manifest, null, '\t');
	fs.writeFileSync('src\\vss-extension.json', manifestContents);
    
    callback();
});

gulp.task('stamp-export-solution-task', ['get-version'], function (callback) {
    stampTaskJson('src\\tasks\\vsts-mscrm-export-solution\\task.json', 'vsts-mscrm-export-solution');
    callback(); 
});

gulp.task('stamp-import-solution-task', ['get-version'], function (callback) {
    stampTaskJson('src\\tasks\\vsts-mscrm-import-solution\\task.json', 'vsts-mscrm-import-solution');
    callback(); 
});

gulp.task('stamp-pack-solution-task', ['get-version'], function (callback) {
    stampTaskJson('src\\tasks\\vsts-mscrm-pack-solution\\task.json', 'vsts-mscrm-pack-solution');
    callback(); 
});

gulp.task('stamp-extract-solution-task', ['get-version'], function (callback) {
    stampTaskJson('src\\tasks\\vsts-mscrm-extract-solution\\task.json', 'vsts-mscrm-extract-solution');
    callback(); 
});

gulp.task('stamp', ['stamp-manifest', 'stamp-export-solution-task', 'stamp-import-solution-task', 'stamp-pack-solution-task', 'stamp-extract-solution-task'], function(callback) {
    callback();
});

gulp.task('pack', ['stamp'], function (callback) {
    exec('node_modules\\.bin\\tfx.cmd extension create --root src', function (err, stdout, stderr) {
        if (err) {
            console.log(stderr);
            callback(err);
        } else {
            console.log(stdout);
            callback();            
        }
    });
});

gulp.task('publish', function (callback) {
    var globPattern = '**/readify.' + channel.id + '-*.vsix';
    glob(globPattern, function (err, files) {
        var vsix = files[0];
        var token = args.token;
        exec('node_modules\\.bin\\tfx.cmd extension publish --vsix ' + vsix + ' --token ' + token, function (err, stdout, stderr) {
            if (err) {
                console.log(stderr);
                callback(err);
            } else {
                console.log(stdout);
                callback();            
            }
        });
    });
});

gulp.task('share', function (callback) {
   var globPattern = '**/readify.' + channel.id + '-*.vsix';
   glob(globPattern, function (err, files) {
      var vsix = files[0];
      var publisher = args.publisher;
      var token = args.token;
      var sharewith = args.sharewith;
      
      exec('node_modules\\.bin\\tfx.cmd extension share --publisher ' + publisher + ' --vsix ' + vsix + ' --token ' + token + ' --share-with ' + sharewith, function (err, stdout, stderr) {
            if (err) {
                console.log(stderr);
                callback(err);
            } else {
                console.log(stdout);
                callback();            
            }          
      });
   });
});

gulp.task('default', ['pack']);