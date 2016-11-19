/*
 * Symphony - A modern community (forum/SNS/blog) platform written in Java.
 * Copyright (C) 2012-2016,  b3log.org & hacpai.com
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.b3log.symphony.util;

import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import org.apache.commons.lang.StringUtils;
import org.b3log.latke.Latkes;
import org.b3log.latke.ioc.LatkeBeanManagerImpl;
import org.b3log.latke.service.LangPropsService;
import org.b3log.latke.service.LangPropsServiceImpl;
import org.b3log.latke.util.Strings;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.parser.Parser;
import org.jsoup.safety.Whitelist;
import org.jsoup.select.Elements;
import static org.parboiled.common.Preconditions.checkArgNotNull;
import org.pegdown.DefaultVerbatimSerializer;
import org.pegdown.Extensions;
import org.pegdown.LinkRenderer;
import org.pegdown.PegDownProcessor;
import org.pegdown.Printer;
import org.pegdown.VerbatimSerializer;
import org.pegdown.ast.AbbreviationNode;
import org.pegdown.ast.AnchorLinkNode;
import org.pegdown.ast.AutoLinkNode;
import org.pegdown.ast.BlockQuoteNode;
import org.pegdown.ast.BulletListNode;
import org.pegdown.ast.CodeNode;
import org.pegdown.ast.DefinitionListNode;
import org.pegdown.ast.DefinitionNode;
import org.pegdown.ast.DefinitionTermNode;
import org.pegdown.ast.ExpImageNode;
import org.pegdown.ast.ExpLinkNode;
import org.pegdown.ast.HeaderNode;
import org.pegdown.ast.HtmlBlockNode;
import org.pegdown.ast.InlineHtmlNode;
import org.pegdown.ast.ListItemNode;
import org.pegdown.ast.MailLinkNode;
import org.pegdown.ast.Node;
import org.pegdown.ast.OrderedListNode;
import org.pegdown.ast.ParaNode;
import org.pegdown.ast.QuotedNode;
import org.pegdown.ast.RefImageNode;
import org.pegdown.ast.RefLinkNode;
import org.pegdown.ast.ReferenceNode;
import org.pegdown.ast.RootNode;
import org.pegdown.ast.SimpleNode;
import org.pegdown.ast.SpecialTextNode;
import org.pegdown.ast.StrikeNode;
import org.pegdown.ast.StrongEmphSuperNode;
import org.pegdown.ast.SuperNode;
import org.pegdown.ast.TableBodyNode;
import org.pegdown.ast.TableCaptionNode;
import org.pegdown.ast.TableCellNode;
import org.pegdown.ast.TableColumnNode;
import org.pegdown.ast.TableHeaderNode;
import org.pegdown.ast.TableNode;
import org.pegdown.ast.TableRowNode;
import org.pegdown.ast.TaskListNode;
import org.pegdown.ast.TextNode;
import org.pegdown.ast.VerbatimNode;
import org.pegdown.ast.Visitor;
import org.pegdown.ast.WikiLinkNode;
import org.pegdown.plugins.ToHtmlSerializerPlugin;

/**
 * <a href="http://en.wikipedia.org/wiki/Markdown">Markdown</a> utilities.
 *
 * <p>
 * Uses the <a href="https://github.com/sirthias/pegdown">pegdown</a> as the converter.
 * </p>
 *
 * @author <a href="http://88250.b3log.org">Liang Ding</a>
 * @author <a href="http://zephyrjung.github.io">Zephyr</a>
 * @version 1.9.8.14, Nov 11, 2016
 * @since 0.2.0
 */
public final class Markdowns {

    /**
     * Language service.
     */
    public static final LangPropsService LANG_PROPS_SERVICE
            = LatkeBeanManagerImpl.getInstance().getReference(LangPropsServiceImpl.class);

    /**
     * Gets the safe HTML content of the specified content.
     *
     * @param content the specified content
     * @param baseURI the specified base URI, the relative path value of href will starts with this URL
     * @return safe HTML content
     */
    public static String clean(final String content, final String baseURI) {
        final Document.OutputSettings outputSettings = new Document.OutputSettings();
        outputSettings.prettyPrint(false);

        final String tmp = Jsoup.clean(content, baseURI, Whitelist.relaxed().
                addAttributes(":all", "id", "target", "class").
                addTags("span", "hr", "kbd", "samp", "tt").
                addAttributes("iframe", "src", "width", "height", "border", "marginwidth", "marginheight").
                addAttributes("audio", "controls", "src").
                addAttributes("video", "controls", "src", "width", "height").
                addAttributes("source", "src", "media", "type").
                addAttributes("object", "width", "height", "data", "type").
                addAttributes("param", "name", "value").
                addAttributes("embed", "src", "type", "width", "height", "wmode", "allowNetworking"),
                outputSettings);
        final Document doc = Jsoup.parse(tmp, baseURI, Parser.xmlParser());

        final Elements ps = doc.getElementsByTag("p");
        for (final Element p : ps) {
            p.removeAttr("style");
        }

        final Elements as = doc.getElementsByTag("a");
        for (final Element a : as) {
            a.attr("rel", "nofollow");

            final String href = a.attr("href");
            if (href.startsWith(Latkes.getServePath())) {
                continue;
            }

            a.attr("target", "_blank");
        }

        final Elements audios = doc.getElementsByTag("audio");
        for (final Element audio : audios) {
            audio.attr("preload", "none");
        }

        final Elements videos = doc.getElementsByTag("video");
        for (final Element video : videos) {
            video.attr("preload", "none");
        }

        return doc.html();
    }

    /**
     * Converts the email or url text to HTML.
     *
     * @param markdownText the specified markdown text
     * @return converted HTML, returns an empty string "" if the specified markdown text is "" or {@code null}, returns
     * 'markdownErrorLabel' if exception
     */
    public static String linkToHtml(final String markdownText) {
        if (Strings.isEmptyOrNull(markdownText)) {
            return "";
        }

        final PegDownProcessor pegDownProcessor = new PegDownProcessor(Extensions.AUTOLINKS, 5000);
        // String ret = pegDownProcessor.markdownToHtml(markdownText);

        final RootNode node = pegDownProcessor.parseMarkdown(markdownText.toCharArray());
        String ret = new ToHtmlSerializer(new LinkRenderer(), Collections.<String, VerbatimSerializer>emptyMap(),
                Arrays.asList(new ToHtmlSerializerPlugin[0])).toHtml(node);
        return ret;
    }
    
    /**
     * Converts the specified markdown text to HTML.
     *
     * @param markdownText the specified markdown text
     * @return converted HTML, returns an empty string "" if the specified markdown text is "" or {@code null}, returns
     * 'markdownErrorLabel' if exception
     */
    public static String toHTML(final String markdownText) {
        if (Strings.isEmptyOrNull(markdownText)) {
            return "";
        }

        final PegDownProcessor pegDownProcessor = new PegDownProcessor(Extensions.ALL_OPTIONALS | Extensions.ALL_WITH_OPTIONALS, 5000);
        // String ret = pegDownProcessor.markdownToHtml(markdownText);

        final RootNode node = pegDownProcessor.parseMarkdown(markdownText.toCharArray());
        String ret = new ToHtmlSerializer(new LinkRenderer(), Collections.<String, VerbatimSerializer>emptyMap(),
                Arrays.asList(new ToHtmlSerializerPlugin[0])).toHtml(node);

        if (!StringUtils.startsWith(ret, "<p>")) {
            ret = "<p>" + ret + "</p>";
        }

        return formatMarkdown(ret);
    }

    /**
     * See https://github.com/b3log/symphony/issues/306.
     *
     * @param markdownText
     * @param tag
     * @return
     */
    private static String formatMarkdown(final String markdownText) {
        String ret = markdownText;
        final Document doc = Jsoup.parse(markdownText, "", Parser.xmlParser());
        final Elements tagA = doc.select("a");
        for (int i = 0; i < tagA.size(); i++) {
            final String search = tagA.get(i).attr("href");
            final String replace = StringUtils.replace(search, "_", "[downline]");
            ret = StringUtils.replace(ret, search, replace);
        }
        final Elements tagImg = doc.select("img");
        for (int i = 0; i < tagImg.size(); i++) {
            final String search = tagImg.get(i).attr("src");
            final String replace = StringUtils.replace(search, "_", "[downline]");
            ret = StringUtils.replace(ret, search, replace);
        }
        final Elements tagCode = doc.select("code");
        for (int i = 0; i < tagCode.size(); i++) {
            final String search = tagCode.get(i).html();
            final String replace = StringUtils.replace(search, "_", "[downline]");
            ret = StringUtils.replace(ret, search, replace);
        }
        
        String[] rets = ret.split("\n");
        for(String temp : rets){
        	final String[] toStrong = StringUtils.substringsBetween(temp, "**", "**");
            final String[] toEm = StringUtils.substringsBetween(temp, "_", "_");
            if (toStrong != null && toStrong.length > 0) {
                for (final String strong : toStrong) {
                    final String search = "**" + strong + "**";
                    final String replace = "<strong>" + strong + "</strong>";
                    ret = StringUtils.replace(ret, search, replace);
                }
            }
            if (toEm != null && toEm.length > 0) {
                for (final String em : toEm) {
                    final String search = "_" + em + "_";
                    final String replace = "<em>" + em + "<em>";
                    ret = StringUtils.replace(ret, search, replace);
                }
            }
        }
        ret = StringUtils.replace(ret, "[downline]", "_");
        return ret;
    }

    /**
     * Private constructor.
     */
    private Markdowns() {
    }

    /**
     * Enhanced with {@link Pangu} for text node.
     */
    private static class ToHtmlSerializer implements Visitor {

        protected Printer printer = new Printer();

        protected final Map<String, ReferenceNode> references = new HashMap<String, ReferenceNode>();

        protected final Map<String, String> abbreviations = new HashMap<String, String>();

        protected final LinkRenderer linkRenderer;

        protected final List<ToHtmlSerializerPlugin> plugins;

        protected TableNode currentTableNode;

        protected int currentTableColumn;

        protected boolean inTableHeader;

        protected Map<String, VerbatimSerializer> verbatimSerializers;

        public ToHtmlSerializer(LinkRenderer linkRenderer) {
            this(linkRenderer, Collections.<ToHtmlSerializerPlugin>emptyList());
        }

        public ToHtmlSerializer(LinkRenderer linkRenderer, List<ToHtmlSerializerPlugin> plugins) {
            this(linkRenderer, Collections.<String, VerbatimSerializer>emptyMap(), plugins);
        }

        public ToHtmlSerializer(final LinkRenderer linkRenderer, final Map<String, VerbatimSerializer> verbatimSerializers) {
            this(linkRenderer, verbatimSerializers, Collections.<ToHtmlSerializerPlugin>emptyList());
        }

        public ToHtmlSerializer(final LinkRenderer linkRenderer, final Map<String, VerbatimSerializer> verbatimSerializers, final List<ToHtmlSerializerPlugin> plugins) {
            this.linkRenderer = linkRenderer;
            this.verbatimSerializers = new HashMap<>(verbatimSerializers);
            if (!this.verbatimSerializers.containsKey(VerbatimSerializer.DEFAULT)) {
                this.verbatimSerializers.put(VerbatimSerializer.DEFAULT, DefaultVerbatimSerializer.INSTANCE);
            }
            this.plugins = plugins;
        }

        public String toHtml(RootNode astRoot) {
            checkArgNotNull(astRoot, "astRoot");
            astRoot.accept(this);
            return printer.getString();
        }

        public void visit(RootNode node) {
            for (ReferenceNode refNode : node.getReferences()) {
                visitChildren(refNode);
                references.put(normalize(printer.getString()), refNode);
                printer.clear();
            }
            for (AbbreviationNode abbrNode : node.getAbbreviations()) {
                visitChildren(abbrNode);
                String abbr = printer.getString();
                printer.clear();
                abbrNode.getExpansion().accept(this);
                String expansion = printer.getString();
                abbreviations.put(abbr, expansion);
                printer.clear();
            }
            visitChildren(node);
        }

        public void visit(AbbreviationNode node) {
        }

        public void visit(AnchorLinkNode node) {
            printLink(linkRenderer.render(node));
        }

        public void visit(AutoLinkNode node) {
            printLink(linkRenderer.render(node));
        }

        public void visit(BlockQuoteNode node) {
            printIndentedTag(node, "blockquote");
        }

        public void visit(BulletListNode node) {
            printIndentedTag(node, "ul");
        }

        public void visit(CodeNode node) {
            printTag(node, "code");
        }

        public void visit(DefinitionListNode node) {
            printIndentedTag(node, "dl");
        }

        public void visit(DefinitionNode node) {
            printConditionallyIndentedTag(node, "dd");
        }

        public void visit(DefinitionTermNode node) {
            printConditionallyIndentedTag(node, "dt");
        }

        public void visit(ExpImageNode node) {
            String text = printChildrenToString(node);
            printImageTag(linkRenderer.render(node, text));
        }

        public void visit(ExpLinkNode node) {
            String text = printChildrenToString(node);
            printLink(linkRenderer.render(node, text));
        }

        public void visit(HeaderNode node) {
            printBreakBeforeTag(node, "h" + node.getLevel());
        }

        public void visit(HtmlBlockNode node) {
            String text = node.getText();
            if (text.length() > 0) {
                printer.println();
            }
            printer.print(text);
        }

        public void visit(InlineHtmlNode node) {
            printer.print(node.getText());
        }

        public void visit(ListItemNode node) {
            if (node instanceof TaskListNode) {
                // vsch: #185 handle GitHub style task list items, these are a bit messy because the <input> checkbox needs to be
                // included inside the optional <p></p> first grand-child of the list item, first child is always RootNode
                // because the list item text is recursively parsed.
                Node firstChild = node.getChildren().get(0).getChildren().get(0);
                boolean firstIsPara = firstChild instanceof ParaNode;
                int indent = node.getChildren().size() > 1 ? 2 : 0;
                boolean startWasNewLine = printer.endsWithNewLine();

                printer.println().print("<li class=\"task-list-item\">").indent(indent);
                if (firstIsPara) {
                    printer.println().print("<p>");
                    printer.print("<input type=\"checkbox\" class=\"task-list-item-checkbox\"" + (((TaskListNode) node).isDone() ? " checked=\"checked\"" : "") + " disabled=\"disabled\"></input>");
                    visitChildren((SuperNode) firstChild);

                    // render the other children, the p tag is taken care of here
                    visitChildrenSkipFirst(node);
                    printer.print("</p>");
                } else {
                    printer.print("<input type=\"checkbox\" class=\"task-list-item-checkbox\"" + (((TaskListNode) node).isDone() ? " checked=\"checked\"" : "") + " disabled=\"disabled\"></input>");
                    visitChildren(node);
                }
                printer.indent(-indent).printchkln(indent != 0).print("</li>")
                        .printchkln(startWasNewLine);
            } else {
                printConditionallyIndentedTag(node, "li");
            }
        }

        public void visit(MailLinkNode node) {
            printLink(linkRenderer.render(node));
        }

        public void visit(OrderedListNode node) {
            printIndentedTag(node, "ol");
        }

        public void visit(ParaNode node) {
            printBreakBeforeTag(node, "p");
        }

        public void visit(QuotedNode node) {
            switch (node.getType()) {
                case DoubleAngle:
                    printer.print("&laquo;");
                    visitChildren(node);
                    printer.print("&raquo;");
                    break;
                case Double:
                    printer.print("&ldquo;");
                    visitChildren(node);
                    printer.print("&rdquo;");
                    break;
                case Single:
                    printer.print("&lsquo;");
                    visitChildren(node);
                    printer.print("&rsquo;");
                    break;
            }
        }

        public void visit(ReferenceNode node) {
            // reference nodes are not printed
        }

        public void visit(RefImageNode node) {
            String text = printChildrenToString(node);
            String key = node.referenceKey != null ? printChildrenToString(node.referenceKey) : text;
            ReferenceNode refNode = references.get(normalize(key));
            if (refNode == null) { // "fake" reference image link
                printer.print("![").print(text).print(']');
                if (node.separatorSpace != null) {
                    printer.print(node.separatorSpace).print('[');
                    if (node.referenceKey != null) {
                        printer.print(key);
                    }
                    printer.print(']');
                }
            } else {
                printImageTag(linkRenderer.render(node, refNode.getUrl(), refNode.getTitle(), text));
            }
        }

        public void visit(RefLinkNode node) {
            String text = printChildrenToString(node);
            String key = node.referenceKey != null ? printChildrenToString(node.referenceKey) : text;
            ReferenceNode refNode = references.get(normalize(key));
            if (refNode == null) { // "fake" reference link
                printer.print('[').print(text).print(']');
                if (node.separatorSpace != null) {
                    printer.print(node.separatorSpace).print('[');
                    if (node.referenceKey != null) {
                        printer.print(key);
                    }
                    printer.print(']');
                }
            } else {
                printLink(linkRenderer.render(node, refNode.getUrl(), refNode.getTitle(), text));
            }
        }

        public void visit(SimpleNode node) {
            switch (node.getType()) {
                case Apostrophe:
                    printer.print("&rsquo;");
                    break;
                case Ellipsis:
                    printer.print("&hellip;");
                    break;
                case Emdash:
                    printer.print("&mdash;");
                    break;
                case Endash:
                    printer.print("&ndash;");
                    break;
                case HRule:
                    printer.println().print("<hr/>");
                    break;
                case Linebreak:
                    printer.print("<br/>");
                    break;
                case Nbsp:
                    printer.print("&nbsp;");
                    break;
                default:
                    throw new IllegalStateException();
            }
        }

        public void visit(StrongEmphSuperNode node) {
            if (node.isClosed()) {
                if (node.isStrong()) {
                    printTag(node, "strong");
                } else {
                    printTag(node, "em");
                }
            } else {
                //sequence was not closed, treat open chars as ordinary chars
                printer.print(node.getChars());
                visitChildren(node);
            }
        }

        public void visit(StrikeNode node) {
            printTag(node, "del");
        }

        public void visit(TableBodyNode node) {
            printIndentedTag(node, "tbody");
        }

        @Override
        public void visit(TableCaptionNode node) {
            printer.println().print("<caption>");
            visitChildren(node);
            printer.print("</caption>");
        }

        public void visit(TableCellNode node) {
            String tag = inTableHeader ? "th" : "td";
            List<TableColumnNode> columns = currentTableNode.getColumns();
            TableColumnNode column = columns.get(Math.min(currentTableColumn, columns.size() - 1));

            printer.println().print('<').print(tag);
            column.accept(this);
            if (node.getColSpan() > 1) {
                printer.print(" colspan=\"").print(Integer.toString(node.getColSpan())).print('"');
            }
            printer.print('>');
            visitChildren(node);
            printer.print('<').print('/').print(tag).print('>');

            currentTableColumn += node.getColSpan();
        }

        public void visit(TableColumnNode node) {
            switch (node.getAlignment()) {
                case None:
                    break;
                case Left:
                    printer.print(" align=\"left\"");
                    break;
                case Right:
                    printer.print(" align=\"right\"");
                    break;
                case Center:
                    printer.print(" align=\"center\"");
                    break;
                default:
                    throw new IllegalStateException();
            }
        }

        public void visit(TableHeaderNode node) {
            inTableHeader = true;
            printIndentedTag(node, "thead");
            inTableHeader = false;
        }

        public void visit(TableNode node) {
            currentTableNode = node;
            printIndentedTag(node, "table");
            currentTableNode = null;
        }

        public void visit(TableRowNode node) {
            currentTableColumn = 0;
            printIndentedTag(node, "tr");
        }

        public void visit(VerbatimNode node) {
            VerbatimSerializer serializer = lookupSerializer(node.getType());
            serializer.serialize(node, printer);
        }

        protected VerbatimSerializer lookupSerializer(final String type) {
            if (type != null && verbatimSerializers.containsKey(type)) {
                return verbatimSerializers.get(type);
            } else {
                return verbatimSerializers.get(VerbatimSerializer.DEFAULT);
            }
        }

        public void visit(WikiLinkNode node) {
            printLink(linkRenderer.render(node));
        }

        public void visit(TextNode node) {
            if (abbreviations.isEmpty()) {
                printer.print(Pangu.spacingText(node.getText()));
            } else {
                printWithAbbreviations(node.getText());
            }
        }

        public void visit(SpecialTextNode node) {
            printer.printEncoded(node.getText());
        }

        public void visit(SuperNode node) {
            visitChildren(node);
        }

        public void visit(Node node) {
            for (ToHtmlSerializerPlugin plugin : plugins) {
                if (plugin.visit(node, this, printer)) {
                    return;
                }
            }
            // override this method for processing custom Node implementations
            throw new RuntimeException("Don't know how to handle node " + node);
        }

        // helpers
        protected void visitChildren(SuperNode node) {
            for (Node child : node.getChildren()) {
                child.accept(this);
            }
        }

        // helpers
        protected void visitChildrenSkipFirst(SuperNode node) {
            boolean first = true;
            for (Node child : node.getChildren()) {
                if (!first) {
                    child.accept(this);
                }
                first = false;
            }
        }

        protected void printTag(TextNode node, String tag) {
            printer.print('<').print(tag).print('>');
            printer.printEncoded(node.getText());
            printer.print('<').print('/').print(tag).print('>');
        }

        protected void printTag(SuperNode node, String tag) {
            printer.print('<').print(tag).print('>');
            visitChildren(node);
            printer.print('<').print('/').print(tag).print('>');
        }

        protected void printBreakBeforeTag(SuperNode node, String tag) {
            boolean startWasNewLine = printer.endsWithNewLine();
            printer.println();
            printTag(node, tag);
            if (startWasNewLine) {
                printer.println();
            }
        }

        protected void printIndentedTag(SuperNode node, String tag) {
            printer.println().print('<').print(tag).print('>').indent(+2);
            visitChildren(node);
            printer.indent(-2).println().print('<').print('/').print(tag).print('>');
        }

        protected void printConditionallyIndentedTag(SuperNode node, String tag) {
            if (node.getChildren().size() > 1) {
                printer.println().print('<').print(tag).print('>').indent(+2);
                visitChildren(node);
                printer.indent(-2).println().print('<').print('/').print(tag).print('>');
            } else {
                boolean startWasNewLine = printer.endsWithNewLine();

                printer.println().print('<').print(tag).print('>');
                visitChildren(node);
                printer.print('<').print('/').print(tag).print('>').printchkln(startWasNewLine);
            }
        }

        protected void printImageTag(LinkRenderer.Rendering rendering) {
            printer.print("<img");
            printAttribute("src", rendering.href);
            // shouldn't include the alt attribute if its empty
            if (!rendering.text.equals("")) {
                printAttribute("alt", rendering.text);
            }
            for (LinkRenderer.Attribute attr : rendering.attributes) {
                printAttribute(attr.name, attr.value);
            }
            printer.print(" />");
        }

        protected void printLink(LinkRenderer.Rendering rendering) {
            printer.print('<').print('a');
            printAttribute("href", rendering.href);
            for (LinkRenderer.Attribute attr : rendering.attributes) {
                printAttribute(attr.name, attr.value);
            }
            printer.print('>').print(rendering.text).print("</a>");
        }

        protected void printAttribute(String name, String value) {
            printer.print(' ').print(name).print('=').print('"').print(value).print('"');
        }

        protected String printChildrenToString(SuperNode node) {
            Printer priorPrinter = printer;
            printer = new Printer();
            visitChildren(node);
            String result = printer.getString();
            printer = priorPrinter;
            return result;
        }

        protected String normalize(String string) {
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < string.length(); i++) {
                char c = string.charAt(i);
                switch (c) {
                    case ' ':
                    case '\n':
                    case '\t':
                        continue;
                }
                sb.append(Character.toLowerCase(c));
            }
            return sb.toString();
        }

        protected void printWithAbbreviations(String string) {
            Map<Integer, Map.Entry<String, String>> expansions = null;

            for (Map.Entry<String, String> entry : abbreviations.entrySet()) {
                // first check, whether we have a legal match
                String abbr = entry.getKey();

                int ix = 0;
                while (true) {
                    int sx = string.indexOf(abbr, ix);
                    if (sx == -1) {
                        break;
                    }

                    // only allow whole word matches
                    ix = sx + abbr.length();

                    if (sx > 0 && Character.isLetterOrDigit(string.charAt(sx - 1))) {
                        continue;
                    }
                    if (ix < string.length() && Character.isLetterOrDigit(string.charAt(ix))) {
                        continue;
                    }

                    // ok, legal match so save an expansions "task" for all matches
                    if (expansions == null) {
                        expansions = new TreeMap<Integer, Map.Entry<String, String>>();
                    }
                    expansions.put(sx, entry);
                }
            }

            if (expansions != null) {
                int ix = 0;
                for (Map.Entry<Integer, Map.Entry<String, String>> entry : expansions.entrySet()) {
                    int sx = entry.getKey();
                    String abbr = entry.getValue().getKey();
                    String expansion = entry.getValue().getValue();

                    printer.printEncoded(string.substring(ix, sx));
                    printer.print("<abbr");
                    if (org.parboiled.common.StringUtils.isNotEmpty(expansion)) {
                        printer.print(" title=\"");
                        printer.printEncoded(expansion);
                        printer.print('"');
                    }
                    printer.print('>');
                    printer.printEncoded(abbr);
                    printer.print("</abbr>");
                    ix = sx + abbr.length();
                }
                printer.print(string.substring(ix));
            } else {
                printer.print(string);
            }
        }
    }
}
