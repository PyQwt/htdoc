"""Generates the www.python.org website style
"""

import os
import posixpath
import time

from Skeleton import Skeleton
from Sidebar import Sidebar, BLANKCELL
from Banner import Banner
from HTParser import HTParser
from LinkFixer import LinkFixer


sitelinks = [
    ('%(rootdir)s/cli-examples.html',     'CLI-Examples'),
    ('%(rootdir)s/download.html',         'Download'),
    ('%(rootdir)s/doc/pyqwt.html',        'Documentation'),
    ('%(rootdir)s/gui-examples.html',     'GUI-Examples'),
    ('%(rootdir)s/home.html',             'Home'),
    ('%(rootdir)s/doc/installation.html', 'Installation'),
    ('%(rootdir)s/license.html',          'License'),
    ('%(rootdir)s/news.html',             'News'),
    ]



import nospam

class NoSpamHTParser(HTParser):
    def __init__(self, filename, default_author=None, default_email=None):
        HTParser.__init__(self, filename, default_author, default_email)

    def process_sidebar(self):
        HTParser.process_sidebar(self)
        author = self.get('author')               # guaranteed
        email = self.get('author-email', author)
        self.sidebar[-1] = (nospam.hide('mailto:' + email),
                            nospam.hide(author))

# class NoSpamHTParser



class PyQwtGenerator(Skeleton, Sidebar, Banner):

    def __init__(self, file, rootdir, relthis):
        root, ext = os.path.splitext(file)
        html = root + '.html'
        p = self.__parser = NoSpamHTParser(file, 'pyqwt-users@lists.sf.net')
        f = self.__linkfixer = LinkFixer(html, rootdir, relthis)
        self.__body = None
        self.__cont = None
        # calculate the sidebar links, adding a few of our own
        self.__d = {'rootdir': rootdir}
        p.process_sidebar()

        # copyrigth
        copyright = self.__parser.get('copyright',
                                      '2001-%d' % time.localtime()[0])
        p.sidebar.append(BLANKCELL)
        p.sidebar.append((None, '&copy; ' + copyright))
        p.sidebar.append((None, 'Gerard Vermeulen'))

        copyright = self.__parser.get('copyright', '2000')
        p.sidebar.append(BLANKCELL)
        p.sidebar.append((None, '&copy; ' + copyright))
        p.sidebar.append((None, 'Mark Colclough'))

        # it is important not to have newlines between the img tag and the end
        # end center tags, otherwise layout gets messed up
        p.sidebar.append(BLANKCELL)
        p.sidebar.append(('http://www.python.org', '''
<center><img alt="Python Powered Logo" border="0" src="%(rootdir)s/images/PythonPowered.png"></center>''' % self.__d))
        # sourceforge link.
        p.sidebar.append(BLANKCELL)
        p.sidebar.append(('http://sourceforge.net', '''
<center><img src="http://sourceforge.net/sflogo.php?group_id=82987&type=2" width="125" height="37" border="0" alt="SourceForge Logo"></center>'''))
        self.__linkfixer.massage(p.sidebar, self.__d)

        Sidebar.__init__(self, p.sidebar)
        #
        # fix up our site links, no relthis because the site links are
        # relative to the root of our web pages
        #
        sitelink_fixer = LinkFixer(f.myurl(), rootdir)
        sitelink_fixer.massage(sitelinks, self.__d, aboves=1)
        Banner.__init__(self, sitelinks)

    # __init__()
   
    def get_stylesheet(self):
        return posixpath.join(self.__d['rootdir'], 'style.css')

    def get_title(self):
        return self.__parser.get('title')

    def get_sidebar(self):
        return Sidebar.get_sidebar(self)

    def get_banner(self):
        return Banner.get_banner(self)

    def get_banner_attributes(self):
        return 'cellspacing="0" cellpadding="5"'

    def get_corner(self):
        # it is important not to have newlines between the img tag and the end
        # anchor and end center tags, otherwise layout gets messed up
        return '<center><b>PyQwt</b></center>'

    def get_corner_bgcolor(self):
        return '#3399ff'

    def get_body(self):
        self.__grokbody()
        return self.__body

    def get_cont(self):
        self.__grokbody()
        return self.__cont

    def __grokbody(self):
        if self.__body is None:
            text = (
                '<center>'
                '<a href="strike.html">'
                '<img alt="patents kill free software" '
                'src="images/no_patents.gif" border=0></a>'
                '</center>\n'
                )
            text += self.__parser.fp.read()
            text = nospam.filter(text)
            i = text.find('<!--table-stop-->')
            if i >= 0:
                self.__body = text[:i]
                self.__cont = text[i+17:]
            else:
                # there is no wide body
                self.__body = text

    # python.org color scheme overrides
    def get_lightshade(self):
        return '#99ccff'

    def get_mediumshade(self):
        return '#3399ff'

    def get_darkshade(self):
        return '#003366'

    def get_charset(self):
        return 'iso-8859-1'

# class PyQwtGenerator
