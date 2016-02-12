var gulp = require('gulp');
var exec = require('child_process').exec;
var minimist = require('minimist');
var semver = require('semver');
var fs = require('fs');

// Default version data. Should be replaced as soon as the get-version task runs.
var version = {
    "Major": 0,
    "Minor": 0,
    "Patch": 1,
    "MajorMinorPatch": "0.0.1",
};

var args = minimist(process.argv);

gulp.task('get-version', function (callback) {
    if (args.overrideversion && semver.valid(args.overrideversion)) {
        version.MajorMinorPatch = args.overrideversion;
        version.Major = semver.major(args.overrideversion);
        version.Minor = semver.minor(args.overrideversion);
        version.Patch = semver.patch(args.overrideversion);
        callback();
    } else {
        exec('gitversion', function(err, stdout, stderr) { 
            version = JSON.parse(stdout);
            callback(err);
        });
    }
});

function stampTaskJson(path) {
    var taskDefinitionContents = fs.readFileSync(path, 'utf8');
	var taskDefinition = JSON.parse(taskDefinitionContents);

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

	manifest.version = version.MajorMinorPatch;

	manifestContents = JSON.stringify(manifest, null, '\t');
	fs.writeFileSync('src\\vss-extension.json', manifestContents);
    
    callback();
});

gulp.task('stamp-export-solution-task', ['get-version'], function (callback) {
    stampTaskJson('src\\tasks\\vsts-mscrm-export-solution\\task.json');
    callback(); 
});

gulp.task('stamp-import-solution-task', ['get-version'], function (callback) {
    stampTaskJson('src\\tasks\\vsts-mscrm-import-solution\\task.json');
    callback(); 
});

gulp.task('stamp-pack-solution-task', ['get-version'], function (callback) {
    stampTaskJson('src\\tasks\\vsts-mscrm-pack-solution\\task.json');
    callback(); 
});

gulp.task('stamp-unpack-solution-task', ['get-version'], function (callback) {
    stampTaskJson('src\\tasks\\vsts-mscrm-unpack-solution\\task.json');
    callback(); 
});

gulp.task('stamp', ['stamp-manifest', 'stamp-export-solution-task', 'stamp-import-solution-task', 'stamp-pack-solution-task', 'stamp-unpack-solution-task'], function(callback) {
    callback();
});

gulp.task('pack', ['stamp'], function (callback) {
    exec('node_modules\\.bin\\tfx.cmd extension create --root src', function (err, stdout, stderr) {
        callback();        
    });
});

gulp.task('default', ['pack']);