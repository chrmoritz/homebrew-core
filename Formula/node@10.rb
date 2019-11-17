class NodeAT10 < Formula
  desc "Platform built on V8 to build network applications"
  homepage "https://nodejs.org/"
  url "https://nodejs.org/dist/v10.17.0/node-v10.17.0.tar.gz"
  sha256 "5204249d135176b547737d3eed2ca8a9d7f731fef6e545f741129cfa21f90573"

  bottle do
    cellar :any
    sha256 "40dd8d0a63109a7382bb82b8acce2a59dec5e287aa16076a53bef58a69505298" => :catalina
    sha256 "b8065c647630356ba9d8cb1aa08a91084fd2c31068fc26b74641a982b5c6d21b" => :mojave
    sha256 "4d7052b587498a1cda140e1190a274a3e4002e1967dfe5dbc29e1cc286a48733" => :high_sierra
  end

  keg_only :versioned_formula

  depends_on "pkg-config" => :build
  depends_on "python" => :build # does not support Python 3
  depends_on "icu4c"

  # Fixes detecting Apple clang 11.
  patch do
    url "https://github.com/nodejs/node/commit/1f143b8625c2985b4317a40f279232f562417077.patch?full_index=1"
    sha256 "12d8af6647e9a5d81f68f610ad0ed17075bf14718f4d484788baac37a0d3f842"
  end

  # apply upstream Python 3 compatibility patches
  patch do # gyp: pull Python 3 changes from node/node-gyp
    url "https://github.com/nodejs/node/commit/b1db810d501079f767579a241c3f613e8a204294.patch?full_index=1"
    sha256 "cb1d581c5de37b3b21a9f8332a9574a9687f49cfc618bb4e5c34381b210c57e1"
  end

  patch do # gyp: cherrypick more Python3 changes from node-gyp
    url "https://github.com/nodejs/node/commit/d630cc0ec5cac7d31d1fd9fa9f4661a53e51a590.patch?full_index=1"
    sha256 ""
  end

  patch do # port Python 3 compat patches from node-gyp to gyp
    url "https://github.com/nodejs/node/commit/41430bea3c4f3164133d5d7b57a403670d0dfa43.patch?full_index=1"
    sha256 ""
  end

  patch do # fix Python 3 syntax error in mac_tool.py
    url "https://github.com/nodejs/node/commit/b6546736a02eb0b52cb4f9a4f5f0383f4b584bfe.patch?full_index=1"
    sha256 ""
  end

  patch do # pull xcode_emulation.py from node-gyp
    url "https://github.com/nodejs/node/commit/b9fd18f9fbed13cd2538f46e0072c923cbfd95cd.patch?full_index=1"
    sha256 ""
  end

  # build: support py3 for configure.py https://github.com/nodejs/node/commit/0a63e2d9ff13e2a1935c04bbd7d57d39c36c3884
  # python3 support for configure https://github.com/nodejs/node/commit/0415dd7cb3f43849f9d6f1f8d271b39c4649c3de
  patch :DATA

  def install
    # make sure subprocesses spawned by make are using our Python 3
    ENV["PYTHON"] = Formula["python"].opt_bin/"python3"

    system "python3", "configure.py", "--prefix=#{prefix}", "--with-intl=system-icu"
    system "make", "install"
  end

  def post_install
    (lib/"node_modules/npm/npmrc").atomic_write("prefix = #{HOMEBREW_PREFIX}\n")
  end

  test do
    path = testpath/"test.js"
    path.write "console.log('hello');"

    output = shell_output("#{bin}/node #{path}").strip
    assert_equal "hello", output
    output = shell_output("#{bin}/node -e 'console.log(new Intl.NumberFormat(\"en-EN\").format(1234.56))'").strip
    assert_equal "1,234.56", output

    output = shell_output("#{bin}/node -e 'console.log(new Intl.NumberFormat(\"de-DE\").format(1234.56))'").strip
    assert_equal "1.234,56", output

    # make sure npm can find node
    ENV.prepend_path "PATH", opt_bin
    ENV.delete "NVM_NODEJS_ORG_MIRROR"
    assert_equal which("node"), opt_bin/"node"
    assert_predicate bin/"npm", :exist?, "npm must exist"
    assert_predicate bin/"npm", :executable?, "npm must be executable"
    npm_args = ["-ddd", "--cache=#{HOMEBREW_CACHE}/npm_cache", "--build-from-source"]
    system "#{bin}/npm", *npm_args, "install", "npm@latest"
    system "#{bin}/npm", *npm_args, "install", "bignum"
    assert_predicate bin/"npx", :exist?, "npx must exist"
    assert_predicate bin/"npx", :executable?, "npx must be executable"
    assert_match "< hello >", shell_output("#{bin}/npx cowsay hello")
  end
end

__END__
diff --git a/configure.py b/configure.py
index 22861a1..c96f8c4 100755
--- a/configure.py
+++ b/configure.py
@@ -11,7 +11,7 @@ import re
 import shlex
 import subprocess
 import shutil
-import string
+import io
 from distutils.spawn import find_executable as which

 # If not run from node/, cd to node/.
@@ -616,11 +616,10 @@ def print_verbose(x):

 def b(value):
   """Returns the string 'true' if value is truthy, 'false' otherwise."""
-  if value:
-    return 'true'
-  else:
-    return 'false'
+  return 'true' if value else 'false'

+def to_utf8(s):
+  return s if isinstance(s, str) else s.decode("utf-8")

 def pkg_config(pkg):
   """Run pkg-config on the specified package
@@ -634,7 +633,7 @@ def pkg_config(pkg):
       proc = subprocess.Popen(
           shlex.split(pkg_config) + ['--silence-errors', flag, pkg],
           stdout=subprocess.PIPE)
-      val = proc.communicate()[0].strip()
+      val = to_utf8(proc.communicate()[0]).strip()
     except OSError as e:
       if e.errno != errno.ENOENT: raise e  # Unexpected error.
       return (None, None, None, None)  # No pkg-config/pkgconf installed.
@@ -649,10 +648,10 @@ def try_check_compiler(cc, lang):
   except OSError:
     return (False, False, '', '')

-  proc.stdin.write('__clang__ __GNUC__ __GNUC_MINOR__ __GNUC_PATCHLEVEL__ '
-                   '__clang_major__ __clang_minor__ __clang_patchlevel__')
+  proc.stdin.write(b'__clang__ __GNUC__ __GNUC_MINOR__ __GNUC_PATCHLEVEL__ '
+                   b'__clang_major__ __clang_minor__ __clang_patchlevel__')

-  values = (proc.communicate()[0].split() + ['0'] * 7)[0:7]
+  values = (to_utf8(proc.communicate()[0]).split() + ['0'] * 7)[0:7]
   is_clang = values[0] == '1'
   gcc_version = tuple(map(int, values[1:1+3]))
   clang_version = tuple(map(int, values[4:4+3])) if is_clang else None
@@ -677,7 +676,7 @@ def get_version_helper(cc, regexp):
        consider adjusting the CC environment variable if you installed
        it in a non-standard prefix.''')

-  match = re.search(regexp, proc.communicate()[1])
+  match = re.search(regexp, to_utf8(proc.communicate()[1]))

   if match:
     return match.group(2)
@@ -696,7 +695,7 @@ def get_nasm_version(asm):
     return '0'

   match = re.match(r"NASM version ([2-9]\.[0-9][0-9]+)",
-                   proc.communicate()[0])
+                   to_utf8(proc.communicate()[0]))

   if match:
     return match.group(1)
@@ -727,7 +726,7 @@ def get_gas_version(cc):
        consider adjusting the CC environment variable if you installed
        it in a non-standard prefix.''')

-  gas_ret = proc.communicate()[1]
+  gas_ret = to_utf8(proc.communicate()[1])
   match = re.match(r"GNU assembler version ([2-9]\.[0-9]+)", gas_ret)

   if match:
@@ -794,10 +793,8 @@ def cc_macros(cc=None):
        consider adjusting the CC environment variable if you installed
        it in a non-standard prefix.''')

-  p.stdin.write('\n')
-  out = p.communicate()[0]
-
-  out = str(out).split('\n')
+  p.stdin.write(b'\n')
+  out = to_utf8(p.communicate()[0]).split('\n')

   k = {}
   for line in out:
@@ -1351,7 +1348,7 @@ def configure_intl(o):
     o['variables']['icu_small'] = b(True)
     locs = set(options.with_icu_locales.split(','))
     locs.add('root')  # must have root
-    o['variables']['icu_locales'] = string.join(locs,',')
+    o['variables']['icu_locales'] = ','.join(str(loc) for loc in locs)
     # We will check a bit later if we can use the canned deps/icu-small
   elif with_intl == 'full-icu':
     # full ICU
@@ -1482,16 +1479,17 @@ def configure_intl(o):
   icu_ver_major = None
   matchVerExp = r'^\s*#define\s+U_ICU_VERSION_SHORT\s+"([^"]*)".*'
   match_version = re.compile(matchVerExp)
-  for line in open(uvernum_h).readlines():
-    m = match_version.match(line)
-    if m:
-      icu_ver_major = m.group(1)
+  with io.open(uvernum_h, encoding='utf8') as in_file:
+    for line in in_file:
+      m = match_version.match(line)
+      if m:
+        icu_ver_major = str(m.group(1))
   if not icu_ver_major:
     error('Could not read U_ICU_VERSION_SHORT version from %s' % uvernum_h)
   elif int(icu_ver_major) < icu_versions['minimum_icu']:
     error('icu4c v%s.x is too old, v%d.x or later is required.' %
           (icu_ver_major, icu_versions['minimum_icu']))
-  icu_endianness = sys.byteorder[0];
+  icu_endianness = sys.byteorder[0]
   o['variables']['icu_ver_major'] = icu_ver_major
   o['variables']['icu_endianness'] = icu_endianness
   icu_data_file_l = 'icudt%s%s.dat' % (icu_ver_major, 'l')
diff --git a/configure.py.orig b/configure.py.orig
index cfd4207..22861a1 100755
--- a/configure.py.orig
+++ b/configure.py.orig
@@ -709,7 +709,7 @@ def get_llvm_version(cc):

 def get_xcode_version(cc):
   return get_version_helper(
-    cc, r"(^Apple LLVM version) ([0-9]+\.[0-9]+)")
+    cc, r"(^Apple (?:clang|LLVM) version) ([0-9]+\.[0-9]+)")

 def get_gas_version(cc):
   try:
