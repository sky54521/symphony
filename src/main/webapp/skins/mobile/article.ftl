<#include "macro-head.ftl">
<#include "macro-pagination-query.ftl">
<!DOCTYPE html>
<html>
    <head>
        <@head title="${article.articleTitle} - ${symphonyLabel}">
        <meta name="keywords" content="<#list article.articleTagObjs as articleTag>${articleTag.tagTitle}<#if articleTag?has_next>,</#if></#list>" />
        <meta name="description" content="${article.articlePreviewContent}"/>
        <#if 1 == article.articleStatus || 1 == article.articleAuthor.userStatus || 1 == article.articleType>
        <meta name="robots" content="NOINDEX,NOFOLLOW" />
        </#if>
        </@head>
        <link rel="stylesheet" href="${staticServePath}/js/lib/highlight.js-9.6.0/styles/github.css">
        <link rel="stylesheet" href="${staticServePath}/js/lib/editor/codemirror.min.css">
        <link rel="stylesheet" href="${staticServePath}/js/lib/aplayer/APlayer.min.css">
    </head>
    <body itemscope itemtype="http://schema.org/Product">
        <img itemprop="image" class="fn-none"  src="${staticServePath}/images/faviconH.png" />
        <p itemprop="description" class="fn-none">"${article.articlePreviewContent}"</p>
        <#include "header.ftl">
        <div class="main">
            <div class="wrapper">
                <div class="article-actions fn-clear">
                    <span class="fn-right">
                        <span id="thankArticle" aria-label="${thankLabel}"
                              class="tooltipped tooltipped-n has-cnt<#if article.thanked> ft-red</#if>"
                              <#if !article.thanked && permissions["commonThankArticle"].permissionGrant>
                                  onclick="Article.thankArticle('${article.oId}', ${article.articleAnonymous})"
                              <#else>
                                  onclick="Article.permissionTip(Label.noPermissionLabel)"
                              </#if>><span class="icon-heart"></span> ${article.thankedCnt}</span>
                        <span class="tooltipped tooltipped-n has-cnt<#if isLoggedIn && 0 == article.articleVote> ft-red</#if>" aria-label="${upLabel}"
                            <#if permissions["commonGoodArticle"].permissionGrant>
                                onclick="Article.voteUp('${article.oId}', 'article', this)"
                            <#else>
                                onclick="Article.permissionTip(Label.noPermissionLabel)"
                            </#if>><span class="icon-thumbs-up"></span> ${article.articleGoodCnt}</span>
                        <span  class="tooltipped tooltipped-n has-cnt<#if isLoggedIn && 1 == article.articleVote> ft-red</#if>" aria-label="${downLabel}"
                            <#if permissions["commonBadArticle"].permissionGrant>
                                onclick="Article.voteDown('${article.oId}', 'article', this)"
                            <#else>
                                onclick="Article.permissionTip(Label.noPermissionLabel)"
                            </#if>><span class="icon-thumbs-down"></span> ${article.articleBadCnt}</span>
                        <#if isLoggedIn && isFollowing>
                            <span class="tooltipped tooltipped-n has-cnt ft-red" aria-label="${uncollectLabel}"
                                <#if permissions["commonFollowArticle"].permissionGrant>
                                    onclick="Util.unfollow(this, '${article.oId}', 'article', ${article.articleCollectCnt})"
                                <#else>
                                    onclick="Article.permissionTip(Label.noPermissionLabel)"
                                </#if>><span class="icon-star"></span> ${article.articleCollectCnt}</span>
                        <#else>
                            <span class="tooltipped tooltipped-n has-cnt" aria-label="${collectLabel}"
                            <#if permissions["commonFollowArticle"].permissionGrant>
                                onclick="Util.follow(this, '${article.oId}', 'article', ${article.articleCollectCnt})"
                            <#else>
                                onclick="Article.permissionTip(Label.noPermissionLabel)"
                            </#if>><span class="icon-star"></span> ${article.articleCollectCnt}</span>
                        </#if>
                        <#if isLoggedIn && isWatching>
                            <span class="tooltipped tooltipped-n has-cnt ft-red" aria-label="${unfollowLabel}"
                            <#if permissions["commonWatchArticle"].permissionGrant>
                                onclick="Util.unfollow(this, '${article.oId}', 'article-watch', ${article.articleWatchCnt})"
                                <#else>
                                    onclick="Article.permissionTip(Label.noPermissionLabel)"
                            </#if>><span class="icon-view"></span> ${article.articleWatchCnt}</span>
                            <#else>
                                <span class="tooltipped tooltipped-n has-cnt" aria-label="${followLabel}"
                                <#if permissions["commonWatchArticle"].permissionGrant>
                                    onclick="Util.follow(this, '${article.oId}', 'article-watch', ${article.articleWatchCnt})"
                                    <#else>
                                        onclick="Article.permissionTip(Label.noPermissionLabel)"
                                </#if>><span class="icon-view"></span> ${article.articleWatchCnt}</span>
                        </#if>
                        <#if 0 < article.articleRewardPoint>
                        <span class="tooltipped tooltipped-n has-cnt<#if article.rewarded> ft-red</#if>"
                        <#if !article.rewarded>onclick="Article.reward(${article.oId})"</#if>
                        aria-label="${rewardLabel}"><span class="icon-points"></span> ${article.rewardedCnt}</span>
                        </#if>
                        <#if article.isMyArticle && 3 != article.articleType && permissions["commonUpdateArticle"].permissionGrant>
                        <a href="${servePath}/update?id=${article.oId}" aria-label="${editLabel}" 
                           class="tooltipped tooltipped-n"><span class="icon-edit"></span></a>
                        </#if>
                        <#if article.isMyArticle && permissions["commonStickArticle"].permissionGrant>
                        <a class="tooltipped tooltipped-n" aria-label="${stickLabel}" 
                           href="javascript:Article.stick('${article.oId}')"><span class="icon-chevron-up"></span></a>
                        </#if>
                        <#if permissions["articleUpdateArticleBasic"].permissionGrant>
                        <a class="tooltipped tooltipped-n" href="${servePath}/admin/article/${article.oId}" aria-label="${adminLabel}"><span class="icon-setting"></span></a>
                        </#if>
                    </span>
                </div>
                <h1 class="article-title" itemprop="name">
                    <#if 1 == article.articlePerfect>
                    <svg height="20" viewBox="3 3 11 12" width="14">${perfectIcon}</svg>
                    </#if>
                    <#if 1 == article.articleType>
                    <span class="icon-locked" title="${discussionLabel}"></span>
                    <#elseif 2 == article.articleType>
                    <span class="icon-feed" title="${cityBroadcastLabel}"></span>
                    <#elseif 3 == article.articleType>
                    <span class="icon-video" title="${thoughtLabel}"></span>
                    </#if>
                    <a class="ft-a-title" href="${servePath}${article.articlePermalink}" rel="bookmark">
                        ${article.articleTitleEmoj}
                    </a>
                </h1>
                <div class="article-info">
                    <#if article.articleAnonymous == 0>
                    <a rel="author" href="${servePath}/member/${article.articleAuthorName}"
                       title="${article.articleAuthorName}"></#if><div class="avatar" style="background-image:url('${article.articleAuthorThumbnailURL48}')"></div><#if article.articleAnonymous == 0></a></#if>
                    <div class="article-params">
                        <#if article.articleAnonymous == 0>
                        <a rel="author" href="${servePath}/member/${article.articleAuthorName}" class="ft-gray"
                           title="${article.articleAuthorName}"></#if><strong>${article.articleAuthorName}</strong><#if article.articleAnonymous == 0></a></#if>
                        <span class="ft-gray">
                        &nbsp;•&nbsp;
                        <a rel="nofollow" class="ft-gray" href="#comments">
                            <b class="article-level<#if article.articleCommentCount lt 40>${(article.articleCommentCount/10)?int}<#else>4</#if>">${article.articleCommentCount}</b> ${cmtLabel}</a>
                        &nbsp;•&nbsp;
                        <span class="article-level<#if article.articleViewCount lt 400>${(article.articleViewCount/100)?int}<#else>4</#if>">
                        <#if article.articleViewCount < 1000>
                        ${article.articleViewCount}
                        <#else>
                        ${article.articleViewCntDisplayFormat}
                        </#if>
                        </span>
                        ${viewLabel}
                        &nbsp;•&nbsp;
                        ${article.timeAgo}
                        <#if article.clientArticlePermalink?? && 0 < article.clientArticlePermalink?length>
                        &nbsp;•&nbsp; <a href="${article.clientArticlePermalink}" target="_blank" rel="nofollow"><span class="ft-green">${sourceLabel}</span></a>
                        </#if>
                    </span>
                        <#if 0 == article.articleAuthor.userUAStatus>
                        <span id="articltVia" class="ft-fade" data-ua="${article.articleUA}"></span>
                        </#if>
                        <div class="article-tags">
                        <#list article.articleTagObjs as articleTag>
                        <a rel="tag" class="tag" href="${servePath}/tag/${articleTag.tagURI}">${articleTag.tagTitle}</a>&nbsp;
                        </#list>
                        </div>
                    </div>
                </div>

                <#if 3 != article.articleType>
                <div class="content-reset article-content">${article.articleContent}</div>
                <#else>
                <div id="thoughtProgress"><span class="bar"></span><span class="icon-video"></span><div data-text="" class="content-reset" id="thoughtProgressPreview"></div></div>
                <div class="content-reset article-content"></div>
                </#if>

                <div class="fn-clear">
                    <div class="share fn-right">
                        <div id="qrCode" class="fn-none"
                             data-shareurl="${servePath}${article.articlePermalink}<#if isLoggedIn>?r=${currentUser.userName}</#if>"></div>
                        <span class="icon-wechat" data-type="wechat"></span>
                        <span class="icon-weibo" data-type="weibo"></span>
                        <span class="icon-twitter" data-type="twitter"></span>
                        <span class="icon-google" data-type="google"></span>
                    </div>
                </div>
                
                <#if 0 < article.articleRewardPoint>
                <div class="content-reset" id="articleRewardContent"<#if !article.rewarded> class="reward"</#if>>
                     <#if !article.rewarded>
                     <span>
                        ${rewardTipLabel?replace("{articleId}", article.oId)?replace("{point}", article.articleRewardPoint)}
                    </span>
                    <#else>
                    ${article.articleRewardContent}
                    </#if>
                </div>
                </#if>
                
                <#if article.articleNiceComments?size != 0>
                    <div class="module nice">
                        <div class="module-header">
                            <span class="icon-thumbs-up ft-blue"></span>
                            ${niceCommentsLabel}
                        </div>
                        <div class="module-panel list comments">
                            <ul>
                            <#list article.articleNiceComments as comment>
                            <li>
                                    <div class="fn-flex">
                                        <#if !comment.fromClient>
                                        <#if comment.commentAnonymous == 0>
                                        <a rel="nofollow" href="${servePath}/member/${comment.commentAuthorName}"></#if>
                                            <div class="avatar tooltipped tooltipped-se"
                                                 aria-label="${comment.commentAuthorName}" style="background-image:url('${comment.commentAuthorThumbnailURL}')"></div>
                                        <#if comment.commentAnonymous == 0></a></#if>
                                        <#else>
                                        <div class="avatar tooltipped tooltipped-se"
                                             aria-label="${comment.commentAuthorName}" style="background-image:url('${comment.commentAuthorThumbnailURL}')"></div>
                                        </#if>
                                        <div class="fn-flex-1">
                                            <div class="fn-clear comment-info ft-smaller">
                                                <span class="fn-left">
                                                    <#if !comment.fromClient>
                                                    <#if comment.commentAnonymous == 0><a rel="nofollow" href="${servePath}/member/${comment.commentAuthorName}" class="ft-gray"></#if><span class="ft-gray">${comment.commentAuthorName}</span><#if comment.commentAnonymous == 0></a></#if>
                                                    <#else><span class="ft-gray">${comment.commentAuthorName}</span>
                                                    <span class="ft-fade"> • </span>
                                                    <a rel="nofollow" class="ft-green" href="https://hacpai.com/article/1457158841475">API</a>
                                                    </#if>
                                                    <span class="ft-fade">• ${comment.timeAgo}</span>

                                                    <#if comment.rewardedCnt gt 0>
                                                    <#assign hasRewarded = isLoggedIn && comment.commentAuthorId != currentUser.oId && comment.rewarded>
                                                    <span aria-label="<#if hasRewarded>${thankedLabel}<#else>${thankLabel} ${comment.rewardedCnt}</#if>"
                                                          class="tooltipped tooltipped-n rewarded-cnt <#if hasRewarded>ft-red<#else>ft-fade</#if>">
                                                        <span class="icon-heart"></span>${comment.rewardedCnt}
                                                    </span>
                                                    </#if>
                                                    <#if 0 == comment.commenter.userUAStatus><span class="cmt-via ft-fade" data-ua="${comment.commentUA}"></span></#if>
                                                </span>
                                                <a class="ft-a-title fn-right tooltipped tooltipped-nw" aria-label="${goCommentLabel}"
                                                   href="javascript:Comment.goComment('${servePath}/article/${article.oId}?p=${comment.paginationCurrentPageNum}&m=${userCommentViewMode}#${comment.oId}')"><span class="icon-down"></span></a>
                                            </div>
                                            <div class="content-reset comment">
                                                ${comment.commentContent}
                                            </div>
                                        </div>
                                    </div>
                                </li>
                            </#list>
                        </ul>
                        </div>
                    </div>
                    </#if>
                    
                <#if 1 == userCommentViewMode>
                <#if isLoggedIn>
                <#if discussionViewable && article.articleCommentable && permissions["commonAddComment"].permissionGrant>
                <div class="form fn-clear comment-wrap">
                    <br/>
                    <div id="replyUseName"> </div>
                    <textarea id="commentContent" placeholder="${commentEditorPlaceholderLabel}"></textarea>
                    <br><br>
                    <div class="tip" id="addCommentTip"></div>

                    <div class="fn-clear comment-submit">
                        <#if permissions["commonAddCommentAnonymous"].permissionGrant>
                        <label class="anonymous-check">${anonymousLabel}<input type="checkbox" id="commentAnonymous"></label>
                        </#if>
                        <button class="red fn-right" onclick="Comment.add('${article.oId}', '${csrfToken}')">${replyLabel}</button>
                    </div>
                </div>
                </#if>
                <#else>
                <div class="comment-login">
                    <a rel="nofollow" href="javascript:Util.needLogin();">${loginDiscussLabel}</a>
                </div>
                </#if>
                </#if>
            </div>
            <div>
                <div class="fn-clear" id="comments">
                    <div class="list comments">
                            <span id="replyUseName" class="fn-none"></span>
                            <div class="comments-header fn-clear">
                            <span class="article-cmt-cnt">${article.articleCommentCount} ${cmtLabel}</span>
                            <span class="fn-right<#if article.articleComments?size == 0> fn-none</#if>">
                                <a class="tooltipped tooltipped-nw" href="javascript:Comment.exchangeCmtSort(${userCommentViewMode})"
                                   aria-label="<#if 0 == userCommentViewMode>${changeToLabel}${realTimeLabel}${cmtViewModeLabel}<#else>${changeToLabel}${traditionLabel}${cmtViewModeLabel}</#if>"><span class="icon-<#if 0 == userCommentViewMode>sortasc<#else>time</#if>"></span></a>&nbsp;
                                <a class="tooltipped tooltipped-nw" href="#bottomComment" aria-label="${jumpToBottomCommentLabel}"><span class="icon-chevron-down"></span></a>
                            </span>
                        </div>
                            <ul>
                                <#if article.articleComments?size == 0>
                                <li class="ft-center fn-pointer"
                                    onclick="$('.article-actions .icon-reply-btn').click()">
                                    <img src="${noCmtImg}" class="article-no-comment-img">
                                </li>
                                </#if>
                                <#assign notificationCmtIds = "">
                                <#list article.articleComments as comment>
                                <#assign notificationCmtIds = notificationCmtIds + comment.oId>
                                <#if comment_has_next><#assign notificationCmtIds = notificationCmtIds + ","></#if>
                                    <#include 'common/comment.ftl' />
                                </#list>
                                <div id="bottomComment"></div>
                            </ul>
                        </div>
                    <@pagination url=article.articlePermalink query="m=${userCommentViewMode}" />
                </div>
                <#if 0 == userCommentViewMode>
                <#if isLoggedIn>
                <#if discussionViewable && article.articleCommentable && permissions["commonAddComment"].permissionGrant>
                <div class="form fn-clear wrapper">
                    <div id="replyUseName"> </div>
                    <textarea id="commentContent" placeholder="${commentEditorPlaceholderLabel}"></textarea>
                    <br><br>
                    <div class="tip" id="addCommentTip"></div>

                    <div class="fn-clear comment-submit">
                        <#if permissions["commonAddCommentAnonymous"].permissionGrant>
                        <label class="anonymous-check">${anonymousLabel}<input type="checkbox" id="commentAnonymous"></label>
                        </#if>
                        <button class="red fn-right" onclick="Comment.add('${article.oId}', '${csrfToken}')">${replyLabel}</button>
                    </div>
                    <div class="fn-hr10"></div>
                    <div class="fn-hr10"></div>
                </div>
                </#if>
                <#else>
                <div class="comment-login wrapper">
                    <a rel="nofollow" href="javascript:Util.needLogin();">${loginDiscussLabel}</a>
                </div>
                <div class="fn-hr10"></div>
                </#if>
                </#if>
            </div>
            <div class="side wrapper">
                <#if ADLabel!="">
                <div class="module">
                    <div class="module-header">
                        <h2>
                            ${sponsorLabel} 
                            <a href="https://hacpai.com/article/1460083956075" class="fn-right ft-13 ft-gray" target="_blank">${wantPutOnLabel}</a>
                        </h2>
                    </div>
                    <div class="module-panel ad fn-clear">
                        ${ADLabel}
                    </div>
                </div>
                </#if>
                <#if sideRelevantArticles?size != 0>
                <div class="module">
                    <div class="module-header">
                        <h2>
                            ${relativeArticleLabel}
                        </h2>
                    </div>
                    <div class="module-panel">
                        <ul class="module-list">
                            <#list sideRelevantArticles as relevantArticle>
                            <li<#if !relevantArticle_has_next> class="last"</#if>>
                                <#if "someone" != relevantArticle.articleAuthorName>
                                <a rel="nofollow" 
                               href="${servePath}/member/${relevantArticle.articleAuthorName}"></#if>
                                    <span class="avatar-small slogan"
                                          style="background-image:url('${relevantArticle.articleAuthorThumbnailURL20}')"></span>
                                    <#if "someone" != relevantArticle.articleAuthorName></a></#if>
                                <a rel="nofollow" class="title" href="${relevantArticle.articlePermalink}">${relevantArticle.articleTitleEmoj}</a>
                            </li>
                            </#list>
                        </ul>
                    </div>
                </div>
                </#if>
                <#if sideRandomArticles?size != 0>
                <div class="module">
                    <div class="module-header">
                        <h2>
                            ${randomArticleLabel}
                        </h2>
                    </div>
                    <div class="module-panel">
                        <ul class="module-list">
                            <#list sideRandomArticles as randomArticle>
                            <li<#if !randomArticle_has_next> class="last"</#if>>
                                <#if "someone" != randomArticle.articleAuthorName>
                                <a  rel="nofollow"
                                href="${servePath}/member/${randomArticle.articleAuthorName}"></#if>
                                    <span class="avatar-small slogan"
                                          style="background-image:url('${randomArticle.articleAuthorThumbnailURL20}')"></span>
                                    <#if "someone" != randomArticle.articleAuthorName></a></#if>
                                <a class="title" rel="nofollow" href="${randomArticle.articlePermalink}">${randomArticle.articleTitleEmoj}</a>
                            </li>
                            </#list>
                        </ul>
                    </div>
                </div>
                </#if>
            </div>
        </div>
        <div id="heatBar">
            <i class="heat" style="width:${article.articleHeat*3}px"></i>
        </div>
        <#include "footer.ftl">
        <script src="${staticServePath}/js/lib/compress/article-libs.min.js"></script>
        <script src="${staticServePath}/js/article${miniPostfix}.js?${staticResourceVersion}"></script>
        <script src="${staticServePath}/js/channel${miniPostfix}.js?${staticResourceVersion}"></script>
        <script>
            Label.commentErrorLabel = "${commentErrorLabel}";
            Label.symphonyLabel = "${symphonyLabel}";
            Label.rewardConfirmLabel = "${rewardConfirmLabel?replace('{point}', article.articleRewardPoint)}";
            Label.thankArticleConfirmLabel = "${thankArticleConfirmLabel?replace('{point}', pointThankArticle)}";
            Label.thankSentLabel = "${thankSentLabel}";
            Label.articleOId = "${article.oId}";
            Label.articleTitle = "${article.articleTitle}";
            Label.recordDeniedLabel = "${recordDeniedLabel}";
            Label.recordDeviceNotFoundLabel = "${recordDeviceNotFoundLabel}";
            Label.csrfToken = "${csrfToken}";
            Label.upLabel = "${upLabel}";
            Label.downLabel = "${downLabel}";
            Label.uploadLabel = "${uploadLabel}";
            Label.userCommentViewMode = ${userCommentViewMode};
            Label.stickConfirmLabel = "${stickConfirmLabel}";
            Label.audioRecordingLabel = '${audioRecordingLabel}';
            Label.uploadingLabel = '${uploadingLabel}';
            Label.copiedLabel = '${copiedLabel}';
            Label.copyLabel = '${copyLabel}';
            Label.noRevisionLabel = "${noRevisionLabel}";
            Label.thankedLabel = "${thankedLabel}";
            Label.thankLabel = "${thankLabel}";
            Label.isAdminLoggedIn = ${isAdminLoggedIn?c};
            Label.adminLabel = '${adminLabel}';
            Label.thankSelfLabel = '${thankSelfLabel}';
            Label.articleAuthorName = '${article.articleAuthorName}';
            Label.replyLabel = '${replyLabel}';
            Label.referenceLabel = '${referenceLabel}';
            Label.goCommentLabel = '${goCommentLabel}';
            Label.commonAtUser = '${permissions["commonAtUser"].permissionGrant?c}';
            Label.qiniuDomain = '${qiniuDomain}';
            Label.qiniuUploadToken = '${qiniuUploadToken}';
            Label.noPermissionLabel = '${noPermissionLabel}';
            <#if isLoggedIn>
                Article.makeNotificationRead('${article.oId}', '${notificationCmtIds}');
                setTimeout(function() {
                    Util.setUnreadNotificationCount();
                }, 1000);
                Label.currentUserName = '${currentUser.userName}';
            </#if>            
            // Init [Article] channel
            ArticleChannel.init("${wsScheme}://${serverHost}:${serverPort}${contextPath}/article-channel?articleId=${article.oId}&articleType=${article.articleType}");
            
            $(document).ready(function () {
                Comment.init();
                
                // jQuery File Upload
                Util.uploadFile({
                    "type": "img",
                    "id": "fileUpload",
                    "pasteZone": $(".CodeMirror"),
                    "qiniuUploadToken": "${qiniuUploadToken}",
                    "editor": Comment.editor,
                    "uploadingLabel": "${uploadingLabel}",
                    "qiniuDomain": "${qiniuDomain}",
                    "imgMaxSize": ${imgMaxSize?c},
                    "fileMaxSize": ${fileMaxSize?c}
                });
            });
            <#if 3 == article.articleType>
                Article.playThought('${article.articleContent}');
            </#if>           
        </script>
    </body>
</html>
