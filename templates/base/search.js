/*
 * $Author$
 * $Revision$
 * $LastChangedDate$
 */

$(document).ready(function(){
	$('#search').keydown(function(e){
		if(e.keyCode == 13){
			$('#search_results').show_results(this.value.toLowerCase());
			return false;
		}
	})
});

(function($){
	$.fn.show_results = function(searchValue){
		var searchTerms = searchValue.split(' ');
		var results=new Array();
		for (term in searchTerms){
			if (results.length)
				results = $.intersectResultsArrays(results,$.getResultsForTerm(searchTerms[term]))
			else
				results = $.getResultsForTerm(searchTerms[term]);
		}
		results.sort($.sortByFirstValue);
		output= new Array();
		while(r = results.shift())
			output.push('<li><span>'+r[0]+'</span><a href="'+r[1]+'">'+r[2]+'</a>');
		this.html('<ol>'+output.join('')+'</ol>');
	};

	$.getResultsForTerm = function(term){
		var foundTerms = new Array();
		var searchTerm=eval('/'+term+'/');
		for(t in terms)
			if (searchTerm.test(t)) foundTerms.push(t);
		var results=new Array();
		var foundDocsIds = new Array();
		for(t in foundTerms){
			for(docs in terms[foundTerms[t]]){
				var id = terms[foundTerms[t]][docs][0];
				var file = files[id];
				if (results[id])
					results[id][0]+=terms[foundTerms[t]][docs][1]*file[2];
				else
					results[id]=[terms[foundTerms[t]][docs][1]*file[2],file[1],file[0]];
			}
		}
		return results;
	}
	$.sortByFirstValue = function(a,b){return b[0]-a[0];};
	$.intersectResultsArrays = function (result1,result2){
		intersectedResults = new Array();
		for (r1 in result1)
			if(result2[r1]) intersectedResults[r1] = [result1[r1][0]+result2[r1][0], result2[r1][1], result2[r1][2]];
		return intersectedResults;
	};
})(jQuery);