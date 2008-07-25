

/*
 * $Author: tom $
 * $Revision: 82 $
 * $LastChangedDate: 2008-02-05 23:35:30 +0100 (Tue, 05 Feb 2008) $
 */

$(document).ready(function(){
	$('#searchInput').keyup(function(e){
		if(e.keyCode == 13){
			var target = ($('#searchresults div').length)? $('#searchresults div') : $.createSearchTarget(document.body);
			$.show_results(this.value.toLowerCase(),target);
			return false;
		}
	});
	$('#searchForm').submit(function(){return false});
});

(function($){
	$.show_results = function(searchValue, target){
		if(searchValue.match(/["'].*[ _\-\(\)].*["']/))
			searchValue = $.quoteSearch(searchValue);
		var searchTerms = searchValue.split(/[^"'a-zA-Z0-9äöüÄÖÜ]/);
		var results=[];
		var no_results = [];
		var temp_result;
		for (var term in searchTerms){
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
		var output= [];
		if(results.length && !no_results.length){
			results.sort($.sortByFirstValue);
			while(r = results.shift())
				output.push('<li><a href="'+rel_path+r[1]+'" target="content">'+r[2]+'</a>');
			target.html('<ol>'+output.join('')+'</ol>');
		}
		else{
			if(no_results.length){
				output.push('<p>Für folgende Begriffe wurden keine Treffer gefunden:</p><ul>');
				for(var t in no_results){
					output.push('<li><strong>'+no_results[t]);
					var dm_check = $.doubleMetaphoneCheck(no_results[t]);
					if(dm_check.length) output.push('</strong> - mögliche Alternativen:<ul><li>'+dm_check.join('</li><li>')+'</li></ul>');
					output.push('</li>');
				}
				target.html(output.join('')+'</ul>');
				}
			else {
				target.html('<p>Es wurden <strong>keine Treffer</strong> gefunden.</p>');}
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
		for(var docs in ranks[terms[searchTerm]]){
			var doc = ranks[terms[searchTerm]][docs].split('-');
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
			for(var docs in ranks[terms[foundTerms[t]]]){
				var doc = ranks[terms[foundTerms[t]]][docs].split('-');
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
		intersectedResults = [];
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
		while(quotes = value.match(/["'](.*[^"'][ _\-\(\)][^"'].*)["']/))
			{
				var terms = quotes[1].split(/[ _\-\(\)]/);
				value = value.replace(/["'].*[^"'][ _\-\(\)][^"'].*["']/,"'"+terms.join("' '")+"'");
			}
		return value;
	};
	
	$.doubleMetaphoneCheck = function(term){
		var result = [];
		var dm = term.doubleMetaphone()
		for(var i in terms){
			if(dm_data[terms[i]][0]==dm[0] || dm_data[terms[i]][0]==dm[1] || dm_data[terms[i]][1]==dm[0] || (dm_data[terms[i]][1]==dm[1] && dm[1] && dm_data[terms[i]][1]))
				result.push([$.levenshtein(i,term),i]);
		}
		result.sort($.sortByFirstValue);
		var out = [];
		for(var i=0,n = result.length;i<n;i++) {out.push(result[i][1]);}
		return out.reverse().slice(0,10);
	};
	
	$.createSearchTarget = function(frame){
		$.search_var=[];
		$.search_var['hiddenElements'] = $(frame).prepend('<div id="searchresults"><h1>Suchergebnisse<span></span></h1><div></div></div>').find('>h1, >ol, >ul').hide();
		frameReset();
		return $('#searchresults', frame).find('h1 span').click(function(){
			$(this.parentNode.parentNode).remove();
			($.search_var['hiddenElements'].length)? $.search_var['hiddenElements'].show() : parent.document.getElementById('mainFrameset').cols = '0,*';
			}).parent().parent().find('div');
	};
	
	$.levenshtein = function(a,b) {
		var cost;
		var m = a.length;
		var n = b.length;
		if (m < n) {
			var c=a;a=b;b=c;
			var o=m;m=n;n=o;
		}
		var r = [[]];
		for (var c = 0; c < n+1; c++) {
			r[0][c] = c;
		}
		for (var i = 1; i < m+1; i++) {
			r[i] = [];
			r[i][0] = i;
			for (var j = 1; j < n+1; j++) {
				cost = (a.charAt(i-1) == b.charAt(j-1))? 0: 1;
				r[i][j] = Math.min(r[i-1][j]+1,r[i][j-1]+1,r[i-1][j-1]+cost);
			}
		}
		return r[m][n];
	}
})(jQuery);

var script = document.createElement('script');
script.type = 'text/javascript';
script.src = '../Suche/search_data.js';
document.getElementsByTagName('head')[0].appendChild(script);