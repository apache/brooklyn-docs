/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

(function($, ZeroClipboard) {
    $('[data-toggle="tooltip"]').tooltip({
        delay: {
            show: 600,
            hide: 100
        }
    });

    $('.page .content').find('h1, h2, h3, h4 ,h5, h6').each(function() {
        var id = $(this).attr('id');
        if (id !== '') {
            $(this).append($('<a>')
                .attr('href', '#' + id)
                .addClass('header-link')
                .html('<i class="fa fa-link"></i>')
            );
        }
    });

    <!-- Copying and clipboard support -->

    // first make the $% line starts not selectable
    $('div.highlight')
        .attr('oncopy', 'handleHideCopy(this)')
        .each(function(index,target) {
            if ($(target).find('code.bash')) {
                // Mark bash prompts from the start of each line (i.e. '$' or '%' characters
                // at the very start, or immediately following any newline) as not-selectable.
                // Handle continuation lines where a leading '$' or '%' is *not* a prompt character.
                // (If example wants to exclude output, it can manually use class="nocopy".)
                target.innerHTML = target.innerHTML.replace(/(^\s*|[^\\]\n)(<.*>)?([$%]|&gt;) /g, '$1$2<span class="nocopy bash_prompt">$3 </span>');
            }
        }).prepend(
            $('<div class="clipboard_container" title="Copy to Clipboard">'+
                '<div class="fa clipboard_button">'+
                '<div class="on-active"><div>Copied to Clipboard</div></div>'+
                '</div></div>')
        );

    $('div.clipboard_container').each(function(index) {
        var clipboard = new ZeroClipboard();
        clipboard.clip( $(this).find(":first")[0], $(this)[0] );
        var target0 = $(this).next();
        var target = target0.clone();
        target.find('.nocopy').remove();
        var txt = target.text();
        clipboard.on( 'dataRequested', function (client, args) {
            handleHideCopy( target0.closest('div.highlight') );  //not necessary but nicer feedback
            client.setText( txt );
        });
    });

    // normal cmd-C (non-icon) copying
    function handleHideCopy(el) {
        // var origHtml = $(el).clone();
        console.log("handling copy", el);
        $(el).addClass('copying');
        $(el).find('.nocopy').hide();
        $(el).find('.clipboard_button').addClass('manual-clipboard-is-active');
        setTimeout(function(){
            $(el).removeClass('copying');
            $(el).find('.clipboard_button').removeClass('manual-clipboard-is-active');
            $(el).find('.nocopy').show();
            // $(el).html(origHtml);
        }, 600);
    }

    <!-- search -->
    $(function() {
        $('#simple_google')
            .submit(function() {
                $('input[name="q"]').val("site:" + document.location.hostname + " " + $('input[name="brooklyn-search"]').val());
                return true;
            });
        $('input[name="brooklyn-search"]').focus(function() {
            if ($(this).val() === $(this).attr('placeholder')) {
                $(this).val('');
            }
        })
            .blur(function() {
                if ($(this).val() === '') {
                    $(this).val($(this).attr('placeholder'));
                }
            })
            .blur();
    });


    <!-- analytics -->
    var _gaq = _gaq || [];
    _gaq.push(['_setAccount', 'UA-30530918-1']);
    _gaq.push(['_trackPageview']);

    (function() {
        var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
        ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
        var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
    })();

    <!-- page warning (for archive pages) -->
    if (document.location.pathname.indexOf('guide/') > -1) {
        if (document.location.pathname.replace(/^\/([^\/]*).*$/, '$1') === "v"){
            var thisversion = document.location.pathname.split("/")[2],
                msg = "";
            if (thisversion != 'latest' && (!$.cookie('brooklyn_versions') ||
                (($.inArray('ALL', $.cookie('brooklyn_versions').split(",")) === -1) &&
                ($.inArray(thisversion, $.cookie('brooklyn_versions').split(",")) === -1))) ){
                msg += "<div class='warning_banner_image'><img src='{{ site.path.style }}/img/warning.png'/></div>";
                msg += "<p>You are browsing the archive site for version <strong>"+thisversion+"</strong>.</p>";
                if (thisversion.indexOf("SNAPSHOT") >= 0) {
                    msg += "<p>Note that SNAPSHOT versions have not been voted on and are not endorsed by the Apache Software Foundation.</p>";
                    msg += "<p>Do you understand and accept the risks?</p>";
                } else {
                    msg += "<p>Is this deliberate?</p>";
                }
                msg += "<center><p class='warning_banner_buttons'>";
                msg += "<a href = 'javascript:void(0);' onclick=\"set_user_version('"+thisversion+"');\">Yes, hide this warning</a>";
                msg += "<a href = '{{ site.path.v }}/latest/'>No, take me to the latest version guide</a>";
                msg += "<a href = '{{ site.path.website }}/meta/versions.html'>Show all versions</a>";
                msg += "</p></center>"

                $('#page_notes').html(msg).fadeIn('slow');
            }
        }
    }
    function get_user_versions() {
        return $.cookie("brooklyn_versions") ? $.cookie("brooklyn_versions").split(",") : [];
    }
    function set_user_version(version) {
        var version_cookie = get_user_versions();
        version_cookie.push(version);
        $.cookie('brooklyn_versions', version_cookie, { expires: 365, path: '/' });
        $('#page_notes').fadeOut();
        event.preventDefault ? event.preventDefault() : event.returnValue = false;
    }
    function set_user_versions_all() {
        var version_cookie = get_user_versions();
        version_cookie.push("ALL");
        $.cookie('brooklyn_versions', version_cookie, { expires: 365, path: '/' });
        $('#page_notes').fadeOut();
        event.preventDefault ? event.preventDefault() : event.returnValue = false;
    }
    function clear_user_versions() {
        $.removeCookie('brooklyn_versions', { path: '/' });
        $('#page_notes').fadeIn('slow');
        event.preventDefault ? event.preventDefault() : event.returnValue = false;
    }
})(jQuery, ZeroClipboard);