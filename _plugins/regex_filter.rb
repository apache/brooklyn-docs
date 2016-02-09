module Jekyll
  module RegexFilter
    def replace_regex(input, reg_str, repl_str)
      re = Regexp.new reg_str, Regexp::MULTILINE

      # This will be returned
      input.gsub re, repl_str
    end
  end
end

Liquid::Template.register_filter(Jekyll::RegexFilter)


#######
# This function rewrites a link in the following manner
#
# 1) If the link is fully external leave it as an unaltered link
# 2) If the link is an anchor, convert to the anchor scheme used in PDF generation
# 3) If the link target is in the PDF, change the link to point at the anchor in the PDF
# 4) If the link is pointing at somewhere on the brooklyn site which is not included in this PDF, point to the website with a specific version, so https://brooklyn.apache.org/v/0.9.0-SNAPSHOT/start/concept-quickstart.html for instance
#
# * Input - the document body, site - the jekyll site object, page - all pages, availablePages - ones included in this merge, mergePage - the root merge page, currentPage - the current page being merged
module RefactorURL
  def refactorURL(input, reg_str, site, pages, availablePages, mergePage, currentPage)
    if input == nil
      return nil
    end
    
    # generate document id, this will be used for the anchors
    $pid = "id-undefined"
    if currentPage['title'] != nil
      $pid = currentPage['title'].downcase.delete('/')
      $pid.gsub!(/\s+/, '-')
    end
    
    # re-write any ids to our internal references
    input.gsub!("id=\"", "id=\"internalLink_"+$pid+"_")
    
    # get rid of any opening in new tabs, they'll break our anchors
    input.gsub!(" target=\"_blank\"", "")
    
    # make a multi-line regex for finding URLs within the document body
    re = Regexp.new reg_str, Regexp::MULTILINE
    
    # for each url matched replace using the following rules
    input.gsub(re) {
      
      $newLink = "#"
      # there should only be one capturing group (the URL), so use the first
      $match = Regexp.last_match.captures[0]
      # the URL is now in match
      if $match.start_with?('http')
        # 1) it's an external link, leave it as it is
        $newLink = $match
      elsif $match.start_with?('#')
        # 2) it's an anchor in the local document re-write with the local document id prefixed  
        $newLink = "#internalLink_"+$pid+"_"+($match.gsub! '#', '')
      else
        # 3/4) it's a link to a page within the site scope
        
        # -- Firstly clean up the URL
        if $match =~ /#/
          # if there's an anchor remove it (anything after the #)
          $match = $match[/[^#]+/]
        end
        # swap ./ for absolute path
        if $match.start_with?('./')
          $match = currentPage['dir']+"/"+$match[2, $match.length]
        # if the string doesnt start with a / it cant be prefixed by the path, so prefix it
        elsif !($match.start_with?('/'))
          $match = currentPage['dir']+"/"+$match
        end
        # add index.html to the end if it's just a folder
        if $match.end_with?('/')
          $match = $match+"index.html"
        end
        
        # -- now work out if the linked to page is within the page scope
        $pageOutOfScope = true;
        for page in availablePages
          if (page['url'] == $match)
            # 3) the page is within the scope of the document, swap it for an anchor
            $pageOutOfScope = false;
#            puts "In Scope "+$match
            # get the pid for this specific page
            $current_pid = page['title'].downcase.delete('/')
            $current_pid.gsub!(/\s+/, '-')
            # make the link an anchor to it
            $newLink = "#contentsLink-"+$current_pid
          end
        end
        # 4) page is out of scope of the document put an absolute URL
        if $pageOutOfScope
#          puts $match+" not in scope - "+$newLink
          $notFoundPrefix = true
          # go through the URL prefixes in the site and swap them for the website paths
          for prefix in site['pdf-rewrite-prefixes']
            
            # make an absolute external URL for the link
            if $match.start_with?(prefix[0])
              $notFoundPrefix = false
              $newLink = site['brooklyn-base-url']+prefix[1]+$match[prefix[0].length, $match.length]
            end
          end 
          if $notFoundPrefix
            puts $match+" not found prefix"
            $newLink = site['brooklyn-base-url']+"/v/"+site['brooklyn-version']+$match
          end
        end
      end
      # return the re-written link wrapped in the property
      "href=\""+$newLink+"\""
    }
  end

  Liquid::Template.register_filter self
end
