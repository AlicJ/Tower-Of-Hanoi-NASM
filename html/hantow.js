console.log("Game Start!");

var peg1 = [0,0,0,0,0,1,2,3];
var peg2 = [0,0,0,0,0,0,0,0];
var peg3 = [0,0,0,0,0,0,0,0];
var pegList = [peg1, peg2, peg3];
var steps = [];

   //          |                        |                        |            
   //          |                        |                        |            
   //          |                        |                        |            
   //          |                        |                        |            
   //          |                        |                        |            
   //         +|+                       |                        |            
   //        ++|++                      |                        |            
   //       +++|+++                     |                        |            
   // XXXXXXXXXXXXXXXXXXX      XXXXXXXXXXXXXXXXXXX      XXXXXXXXXXXXXXXXXXX   


function draw() {
	// loop through all elements in each list
	for (var i=0; i<8; i++){
		var ord = i
		$.each(pegList, function(index, peg) {
			/* iterate through array or object */
			var disk = peg[ord];
			var numOfSpace = 9 - disk;
			var string = "";
			for (var i=0; i<numOfSpace; i++) {
				string += "&nbsp;";
			}
			for (var i=0; i<disk; i++) {
				string += "+";
			}
			string += "|";
			for (var i=0; i<disk; i++) {
				string += "+";
			}
			for (var i=0; i<numOfSpace+5; i++) {
				string += "&nbsp;";
			}
			$('body').append(string);
		});
		$('body').append("<br/>");
	}
	var string = "";
	for (var i=0; i<3; i++){
		for (var j=0; j<19; j++){
			string += '#';
		}
		for (var k=0; k<5; k++){
			string += "&nbsp;";
		}
	}
	$('body').append(string+"<br/>");
}

function size() {
	var peg = pegList[0];
	var count = 0
	for (var i=0; i<8; i++){
		var disk = peg[i];
		if(disk == 0){
			continue;
		}
		count ++;
	}
	return count;
}


function hanoi(disc, from, to , via) {
	if (disc <= 0) return;

	hanoi(disc-1, from, via , to);
	steps.push([from-1,to-1]); // save parameters to callStack array
	console.log('Move disc ' + disc + ' from ' + from + ' to ' + to);
	hanoi(disc-1, via, to , from);

}

function move () {

	var param = steps.shift();

	var fromPeg = param[0];
	var toPeg = param[1];
	var diskNum = 0;

	for (var i=0; i<8; i++) {
		var d = pegList[fromPeg][i];
		var cur = i;
		if (d != 0) {
			pegList[fromPeg][cur] = 0;
			diskNum = d;
			console.log(pegList);
			break;
		}
	}

	for (var i=7; i>=0; i--) {
		var d = pegList[toPeg][i];
		var cur = i;
		if (d == 0) {
			pegList[toPeg][cur] = diskNum;
			console.log(pegList);
			break;
		}
	}
	console.log(param);
	console.log(pegList);
	draw();
}


$(document).ready(function() {
	$('body').html('<h1>Tower of Hanoi</h1>');
	var n = size();
	console.log(n);
	console.log(pegList);

	draw();

	hanoi(3, 1, 2, 3);

	while (steps.length > 0)
		move();

	console.log(pegList);
});