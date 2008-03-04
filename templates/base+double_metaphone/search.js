/*
 * $Author: tom $
 * $Revision: 82 $
 * $LastChangedDate: 2008-02-05 23:35:30 +0100 (Tue, 05 Feb 2008) $
 */

$(document).ready(function(){
	$('#search').keyup(function(e){
		if(e.keyCode == 13){
			$('#search_results').show_results(this.value.toLowerCase());
			return false;
		}
	})
});

(function($){
	$.fn.show_results = function(searchValue){
		if(searchValue.match(/["'].*[ _\-\(\)].*["']/))
			searchValue = $.quoteSearch(searchValue);
		var searchTerms = searchValue.split(/[ _\-\(\)]/);
		var results=new Array();
		var no_results = new Array();
		var temp_result;
		for (term in searchTerms){
			if(searchTerms[term].length > 1){
				temp_result = $.getResultsForTerm(searchTerms[term]);
				if(temp_result.length)
				{
					if (results.length)
						results = $.intersectResultsArrays(results,temp_result);
					else
						results = temp_result;
				}
				else{
					no_results.push(searchTerms[term]);
					}
			}
		}
		var output= new Array();
		if(results.length && !no_results.length){
			results.sort($.sortByFirstValue);
			while(r = results.shift())
				output.push('<li><span>'+r[0]+'</span><a href="'+rel_path+r[1]+'">'+r[2]+'</a>');
			this.html('<ol>'+output.join('')+'</ol>');
		}
		else{
			output.push('<p>No results found for:</p><ul>');
			for(var t in no_results){
				output.push('<li><strong>'+no_results[t]+'</strong> (possible alternatives:'+$.doubleMetaphoneCheck(no_results[t].doubleMetaphone())+')</li>');
				}
			this.html(output.join('')+'</ul>');
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
		var results=new Array();
		for(docs in terms[searchTerm]){
			var id = terms[searchTerm][docs][0];
			var file = files[id];
			if (results[id])
				results[id][0]+=terms[searchTerm][docs][1]*1.5;
			else
				results[id]=[terms[searchTerm][docs][1]*1.5+file[2],file[1],file[0]];
		}
		return results;
	}
	$.fuzzySearch = function(searchTerm){
		var foundTerms = new Array();
		for(t in terms)
			if (searchTerm.test(t)) foundTerms.push(t);
		var results=new Array();
		var foundDocsIds = new Array();
		for(t in foundTerms){
			for(docs in terms[foundTerms[t]]){
				var id = terms[foundTerms[t]][docs][0];
				var file = files[id];
				if (results[id])
					results[id][0]+=terms[foundTerms[t]][docs][1];
				else
					results[id]=[terms[foundTerms[t]][docs][1]+file[2],file[1],file[0]];
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
	$.mergeResultArrays = function(lesser, greater){
		for (r in greater)
			if(lesser[r]) greater[r][0]+=lesser[r][0];
		return greater;
	}
	
	$.quoteSearch = function(value){
		while(quotes = value.match(/["'](.*[^"'][ _\-\(\)][^"'].*)["']/))
			{
				var terms = quotes[1].split(/[ _\-\(\)]/);
				value = value.replace(/["'].*[^"'][ _\-\(\)][^"'].*["']/,"'"+terms.join("' '")+"'");
			}
		return value;
	};
	
	$.doubleMetaphoneCheck = function(dm){
		var result = [];
		for(i in dm_data){
			if(dm_data[i][0]==dm[0] || dm_data[i][0]==dm[1] || dm_data[i][1]==dm[0] || (dm_data[i][1]==dm[1] && dm[1] && dm_data[i][1]))
				result.push(i);
		}
		return result;
	};
	
})(jQuery);