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
	$.lang = {
		no_entries: 'Keine Einträge gefunden.'
	};
	$.fn.show_results = function(searchValue){
		if(searchValue.match(/["'].*[^a-zA-ZÄÖÜäöüß].*["']/))
			searchValue = $.quoteSearch(searchValue);
		var searchTerms = searchValue.split(/[^a-zA-ZÄÖÜäöüß]/);
		var results=[];
		for (var term in searchTerms){
			if(searchTerms[term].length > 1){
				if (results.length)
					results = $.intersectResultsArrays(results,$.getResultsForTerm(searchTerms[term]))
				else
					results = $.getResultsForTerm(searchTerms[term]);
			}
		}
		results.sort($.sortByFirstValue);
		var output = [];
		if(results.length){
			var r;
			while(r = results.shift())
				output.push('<li><a href="'+rel_path+r[1]+'">'+r[2]+'</a>');
			this.html('<ol>'+output.join('')+'</ol>');
		}
		else{
			this.html('<p><strong>'+$.lang.no_entries+'</strong></p>');
		}
	};
	$.getResultsForTerm = function(term){
		var exact_term = /^["'][^"']+["']$/.test(term);
		term = term.replace(/["']/g,'');
		if(exact_term)
			return $.exactSearch(term);
		else
		return $.mergeResultArrays($.exactSearch(term),$.fuzzySearch(eval('/'+term+'/')));
	}
	$.exactSearch = function(searchTerm){
		var results=[];
		for(var docs in terms[searchTerm]){
			var doc = terms[searchTerm][docs].split('-');
			doc[1]=parseInt(doc[1]);
			var file = files[doc[0]];
			if (results[doc[0]])
				results[doc[0]][0]+=doc[1]*1.5;
			else
				results[doc[0]]=[doc[1]*1.5+file[2],file[1],file[0]];
		}
		return results;
	}
	$.fuzzySearch = function(searchTerm){
		var foundTerms = [];
		for(var t in terms)
			if (searchTerm.test(t)) foundTerms.push(t);
		var results= [];
		var foundDocsIds = [];
		for(var t in foundTerms){
			for(var docs in terms[foundTerms[t]]){
				var doc = terms[foundTerms[t]][docs].split('-');
				doc[1]=parseInt(doc[1]);
				var file = files[doc[0]];
				if (results[doc[0]])
					results[doc[0]][0]+=doc[1];
				else
					results[doc[0]]=[doc[1]+file[2],file[1],file[0]];
			}
		}
		return results;
	}

	$.sortByFirstValue = function(a,b){return b[0]-a[0];};
	$.intersectResultsArrays = function (result1,result2){
		var intersectedResults = [];
		for (var r1 in result1)
			if(result2[r1]) intersectedResults[r1] = [result1[r1][0]+result2[r1][0], result2[r1][1], result2[r1][2]];
		return intersectedResults;
	};
	$.mergeResultArrays = function(lesser, greater){
		for (var r in greater)
			if(lesser[r]) greater[r][0]+=lesser[r][0];
		return greater;
	}

	$.quoteSearch = function(value){
		var quotes;
		while(quotes = value.match(/["'](.*[^"'][^'"a-zA-ZÄÖÜäöüß][^"'].*)["']/))
			{
				var terms = quotes[1].split(/[^'"a-zA-ZÄÖÜäöüß]/);
				value = value.replace(/["'].*[^"'][^'"a-zA-ZÄÖÜäöüß][^"'].*["']/,"'"+terms.join("' '")+"'");
			}
		return value.replace(/''/g,' ').replace(/ +/,' ');
	};

})(jQuery);
