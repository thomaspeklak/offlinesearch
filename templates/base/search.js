/*
 * $Autor$
 * $Revision$
 * $LastChangedDate$
 */

$(document).ready(function(){
	$('#search').keydown(function(e){
		if(e.keyCode == 13){
			$('#search_results').show_results(this.value);
			return false;
		}
	})
});

(function($){
	$.fn.show_results = function(term){
		results=new Array;
		for(doc in terms[term]){
			file = files[terms[term][doc][0]];
			results.push([terms[term][doc][1]*file[2],'<li>'+terms[term][doc][1]*file[2]+'<a href="'+file[1]+'">'+file[0]+'</a></li>']);
		}
		results.sort($.sortByFirstValue);
		
		output=new Array;
		for(i in results)
			output.push(results[i][1]);
		this.html('<ol>'+output.join('')+'</ol>');
	};
	$.get_matches = function (term) {
		
	};
	
	$.sortByFirstValue = function(a,b){return b[0]-a[0];};
	
})(jQuery);