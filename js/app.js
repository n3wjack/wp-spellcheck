
function ResultController($scope) {
    
    // Get the JSON data from the spellcheckdata.js include.
    $scope.spellcheckdata = spellcheckdata;

    for (var i = 0; i < $scope.spellcheckdata.length; i++) {
        $scope.spellcheckdata[i].ignored = false;
    }

    $scope.totalWords = spellcheckdata.length;

    $scope.ignore = function ($data) {
        alert($data);
    }
}

