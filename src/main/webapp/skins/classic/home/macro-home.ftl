<#macro home type>
<#include "../macro-head.ftl">
<!DOCTYPE html>
<html>
    <head>
        <#if type == "home">
        <@head title="${articleLabel} - ${user.userName} - ${symphonyLabel}">
        <meta name="description" content="<#list userHomeArticles as article><#if article_index<3>${article.articleTitle},</#if></#list>"/>
        </@head>
        <#elseif type == "comments">
        <@head title="${cmtLabel} - ${user.userName} - ${symphonyLabel}">
        <meta name="description" content="${user.userName}${deLabel}${cmtLabel}"/>
        <link rel="stylesheet" href="${staticServePath}/js/lib/highlight.js-9.6.0/styles/github.css">
        </@head>
        <#elseif type == "followingUsers">
        <@head title="${followingUsersLabel} - ${user.userName} - ${symphonyLabel}">
        <meta name="description" content="${user.userName}${deLabel}${followingUsersLabel}"/>
        </@head>
        <#elseif type == "followingTags">
        <@head title="${followingTagsLabel} - ${user.userName} - ${symphonyLabel}">
        <meta name="description" content="${user.userName}${deLabel}${followingTagsLabel}"/>
        </@head>
        <#elseif type == "followingArticles">
        <@head title="${followingArticlesLabel} - ${user.userName} - ${symphonyLabel}">
        <meta name="description" content="${user.userName}${deLabel}${followingArticlesLabel}"/>
        </@head>
        <#elseif type == "watchingArticles">
            <@head title="${watchingArticlesLabel} - ${user.userName} - ${symphonyLabel}">
            <meta name="description" content="${user.userName}${deLabel}${watchingArticlesLabel}"/>
        </@head>
        <#elseif type == "followers">
        <@head title="${followersLabel} - ${user.userName} - ${symphonyLabel}">
        <meta name="description" content="${user.userName}${deLabel}${followersLabel}"/>
        </@head>
        <#elseif type == "points">
        <@head title="${pointLabel} - ${user.userName} - ${symphonyLabel}">
        <meta name="description" content="${user.userName}${deLabel}${pointLabel}"/>
        </@head>
        <#elseif type == "settings">
        <@head title="${settingsLabel} - ${user.userName} - ${symphonyLabel}">
        <meta name="description" content="${user.userName}${deLabel}${settingsLabel}"/>
        </@head>
        <#elseif type == "articlesAnonymous">
        <@head title="${anonymousArticleLabel} - ${user.userName} - ${symphonyLabel}">
        <meta name="description" content="${user.userName}${deLabel}${anonymousArticleLabel}"/>
        </@head>
        <#elseif type == "commentsAnonymous">
        <@head title="${anonymousCommentLabel} - ${user.userName} - ${symphonyLabel}">
        <meta name="description" content="${user.userName}${deLabel}${anonymousCommentLabel}"/>
        <link rel="stylesheet" href="${staticServePath}/js/lib/highlight.js-9.6.0/styles/github.css">
        </@head>
        <#elseif type == "linkForge">
        <@head title="${linkForgeLabel} - ${user.userName} - ${symphonyLabel}">
        <meta name="description" content="${user.userName}${deLabel}${linkForgeLabel}"/>
        </@head>
        </#if>
        <link rel="stylesheet" href="${staticServePath}/css/home.css?${staticResourceVersion}" />
    </head>
    <body>
        <#include "../header.ftl">
        <div class="main">
            <div class="wrapper">
                <div class="content">
                    <div<#if type != "linkForge"> class="module"</#if>>
                    <#nested>
                    </div>
                </div>
                <div class="side">
                    <#include "home-side.ftl">
                    <div class="module">
                        <div class="module-header"><h2>${goHomeLabel}</h2></div> 
                        <div class="module-panel fn-oh">
                            <nav class="home-menu">
                                <a <#if type == "home" || type == "comments" || type == "articlesAnonymous" || type == "commentsAnonymous">
                                    class="current"</#if>
                                    href="${servePath}/member/${user.userName}"><svg height="18" viewBox="0 1 16 16" width="16">${boolIcon}</svg> ${postLabel}</a>
                                <a <#if type == "followingUsers" || type == "followingTags" || type == "followingArticles" || type == "followers"> class="current"</#if>
                                    href="${servePath}/member/${user.userName}/watching/articles"><svg height="18" viewBox="0 1 14 16" width="14">${starIcon}</svg> ${followLabel}</a>
                                <a <#if type == "points"> class="current"</#if> href="${servePath}/member/${user.userName}/points">
                                    <svg height="18" viewBox="0 1 14 16" width="14">${giftIcon}</svg> ${pointLabel}</a>
                                <a <#if type == "linkForge"> class="current"</#if> href="${servePath}/member/${user.userName}/forge/link">
                                    <svg height="18" viewBox="0 1 16 16" width="16">${baguaIcon}</svg>  ${forgeLabel}</a>
                                <#if currentUser?? && currentUser.userName == user.userName>
                                <a <#if type == "settings"> class="selected"</#if>
                                    href="${servePath}/settings"><svg height="18" viewBox="0 1 14 16" width="14">${settingIcon}</svg> ${settingsLabel}</a>
                                </#if>
                            </nav>
                        </div>
                    </div>
                </div>
        </div>
            </div>
        <#include "../footer.ftl">
        <script src="${staticServePath}/js/settings${miniPostfix}.js?${staticResourceVersion}"></script>
        <script>
            Label.followLabel = "${followLabel}";
            Label.unfollowLabel = "${unfollowLabel}";
            Label.invalidPasswordLabel = "${invalidPasswordLabel}";
            Label.amountNotEmpty = "${amountNotEmpty}";
            Label.invalidUserNameLabel = "${invalidUserNameLabel}";
            Label.loginNameErrorLabel = "${loginNameErrorLabel}";
            Label.updateSuccLabel = "${updateSuccLabel}";
            Label.transferSuccLabel = "${transferSuccLabel}";
            Label.invalidUserURLLabel = "${invalidUserURLLabel}";
            Label.tagsErrorLabel = "${tagsErrorLabel}";
            Label.invalidUserQQLabel = "${invalidUserQQLabel}";
            Label.invalidUserIntroLabel = "${invalidUserIntroLabel}";
            Label.invalidUserB3KeyLabel = "${invalidUserB3KeyLabel}";
            Label.invalidUserB3ClientURLLabel = "${invalidUserB3ClientURLLabel}";
            Label.confirmPwdErrorLabel = "${confirmPwdErrorLabel}";
            Label.invalidUserNicknameLabel = "${invalidUserNicknameLabel}";
            Label.forgeUploadSuccLabel = "${forgeUploadSuccLabel}";
            <#if type == 'commentsAnonymous' || 'comments' == type>
            Settings.initHljs();
            </#if>
            <#if type == 'linkForge'>
                Util.linkForge();
            </#if>
        </script>
    </body>
</html>
</#macro>
