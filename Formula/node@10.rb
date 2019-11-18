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
    sha256 "5fb67bbd49b23b589383b24cab21ca6ca5143c0d01f048d2777f9f57cf75e5fb"
  end

  patch do # tools: fix Python 3 issues in gyp/generator/make.py
    url "https://github.com/nodejs/node/commit/eceebd3ef1f40671073e822910c247a71935cb84.patch?full_index=1"
    sha256 "738cebf393103665d8ea53c0581ee204575fabadd89dc01db2911d8182ab077f"
  end

  patch do # tools: port Python 3 compat patches from node-gyp to gyp
    url "https://github.com/nodejs/node/commit/66b953207d6f0e9c98155af97147a731b2e461bd.patch?full_index=1"
    sha256 "e677e8a81e0b59dc744fd833f102f8a3581f9c1937ab99d3bc0a1f5acbb34b58"
  end

  patch do # gyp: futurize imput.py to prepare for Python 3
    url "https://github.com/nodejs/node/commit/10bae2ec919b26f2f8be5182f3e751d8e2726ec2.patch?full_index=1"
    sha256 "f08da2850679ab0442a5911772da362ce0449571af0fac7c73db6a69323acd27"
  end

  patch do # tools: make nodedownload.py Python 3 compatible
    url "https://github.com/nodejs/node/commit/31c50e5c17aaca2389fef65b8bb9c4c3a100585a.patch?full_index=1"
    sha256 "77922e9d785d6ab1d7f0b34741e2770a22c65e7c6184cf78ced14c2404e3c1f1"
  end

  patch do # tools: use 'from io import StringIO' in ninja.py
    url "https://github.com/nodejs/node/commit/350975e312b706c9185a94cf0e049b994f60ae22.patch?full_index=1"
    sha256 "8d486403a7e6d92cf6d95e4a54298218b4d1cf6861bd1e87b41abb7266847439"
  end

  patch do # gyp: make StringIO work in ninja.py
    url "https://github.com/nodejs/node/commit/a20a8f48f7b9b8243dd6db03e3fb2cd058208c03.patch?full_index=1"
    sha256 "8ccb2cd1d6c8c9b8847aecf97896a268f457074899968080a5ac6c9f36a1b061"
  end

  patch do # tools: fix GYP ninja generator for Python 3
    url "https://github.com/nodejs/node/commit/2f81d59e754b4564db7a3450280612e4e5f9079a.patch?full_index=1"
    sha256 "60f425b69de8f6516238f486de1d010ff34818234900656118528b025b3a9e57"
  end

  patch do # tools: fix Python 3 syntax error in mac_tool.py
    url "https://github.com/nodejs/node/commit/9529c6660f5cc0de106a60f78d9dbafb6ccea26a.patch?full_index=1"
    sha256 "d3a56d88c7fc0e09e809a813b1e2ce52fce0ccceecfb5bd69154cf2437ebbf69"
  end

  patch do # tools: pull xcode_emulation.py from node-gyp
    url "https://github.com/nodejs/node/commit/0673dfc0d8944a37e17fbaa683022f4b9e035577.patch?full_index=1"
    sha256 "a682d597fb63861a3ae812345ade7ad2b1125b3362317e247b4fb52ecd7532be"
  end

  # build: support py3 for configure.py https://github.com/nodejs/node/commit/0a63e2d9ff13e2a1935c04bbd7d57d39c36c3884
  # python3 support for configure https://github.com/nodejs/node/commit/0415dd7cb3f43849f9d6f1f8d271b39c4649c3de
  # build: always use strings for compiler version in gyp files https://github.com/nodejs/node/commit/ca10dff0cb23342ba512ae2495291e6457a54edb
  # deps: V8: cherry-pick e3d7f8a [build] update gen-postmortem-metadata for Python 3 https://github.com/nodejs/node/commit/a17d398989b9606e4fdc188cb5988cd669ce5edd
  # fix deps/v8/tools/node/* (use print function) from newer V8 versions
  # fixes to tools/js2c.py from https://github.com/nodejs/node/commit/0db846f73407c5df60f86211dc29eac053ff124c
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
diff --git a/deps/v8/tools/node/fetch_deps.py b/deps/v8/tools/node/fetch_deps.py
index 26b9d6a..8bc2133 100755
--- a/deps/v8/tools/node/fetch_deps.py
+++ b/deps/v8/tools/node/fetch_deps.py
@@ -51,9 +51,9 @@ def EnsureGit(v8_path):
   expected_git_dir = os.path.join(v8_path, ".git")
   actual_git_dir = git("rev-parse --absolute-git-dir")
   if expected_git_dir == actual_git_dir:
-    print "V8 is tracked stand-alone by git."
+    print("V8 is tracked stand-alone by git.")
     return False
-  print "Initializing temporary git repository in v8."
+  print("Initializing temporary git repository in v8.")
   git("init")
   git("config user.name \"Ada Lovelace\"")
   git("config user.email ada@lovela.ce")
@@ -70,7 +70,7 @@ def FetchDeps(v8_path):

   temporary_git = EnsureGit(v8_path)
   try:
-    print "Fetching dependencies."
+    print("Fetching dependencies.")
     env = os.environ.copy()
     # gclient needs to have depot_tools in the PATH.
     env["PATH"] = depot_tools + os.pathsep + env["PATH"]


diff --git a/deps/v8/tools/node/node_common.py b/deps/v8/tools/node/node_common.py
index de2e98d..860c606 100755
--- a/deps/v8/tools/node/node_common.py
+++ b/deps/v8/tools/node/node_common.py
@@ -22,7 +22,7 @@ def EnsureDepotTools(v8_path, fetch_if_not_exist):
     except:
       pass
     if fetch_if_not_exist:
-      print "Checking out depot_tools."
+      print("Checking out depot_tools.")
       # shell=True needed on Windows to resolve git.bat.
       subprocess.check_call("git clone {} {}".format(
           pipes.quote(DEPOT_TOOLS_URL),
@@ -31,14 +31,14 @@ def EnsureDepotTools(v8_path, fetch_if_not_exist):
     return None
   depot_tools = _Get(v8_path)
   assert depot_tools is not None
-  print "Using depot tools in %s" % depot_tools
+  print("Using depot tools in %s" % depot_tools)
   return depot_tools

 def UninitGit(v8_path):
-  print "Uninitializing temporary git repository"
+  print("Uninitializing temporary git repository")
   target = os.path.join(v8_path, ".git")
   if os.path.isdir(target):
-    print ">> Cleaning up %s" % target
+    print(">> Cleaning up %s" % target)
     def OnRmError(func, path, exec_info):
       # This might happen on Windows
       os.chmod(path, stat.S_IWRITE)
diff --git a/deps/v8/gypfiles/toolchain.gypi b/deps/v8/gypfiles/toolchain.gypi
index fbf6832..1829ebe 100644
--- a/deps/v8/gypfiles/toolchain.gypi
+++ b/deps/v8/gypfiles/toolchain.gypi
@@ -41,7 +41,7 @@
     'has_valgrind%': 0,
     'coverage%': 0,
     'v8_target_arch%': '<(target_arch)',
-    'v8_host_byteorder%': '<!(python -c "import sys; print sys.byteorder")',
+    'v8_host_byteorder%': '<!(python -c "import sys; print(sys.byteorder)")',
     'force_dynamic_crt%': 0,

     # Setting 'v8_can_use_vfp32dregs' to 'true' will cause V8 to use the VFP
diff --git a/configure.py b/configure.py
index 5d57338..2e35801 100755
--- a/configure.py
+++ b/configure.py
@@ -681,7 +681,7 @@ def get_version_helper(cc, regexp):
   if match:
     return match.group(2)
   else:
-    return '0'
+    return '0.0'

 def get_nasm_version(asm):
   try:
@@ -692,7 +692,7 @@ def get_nasm_version(asm):
     warn('''No acceptable ASM compiler found!
          Please make sure you have installed NASM from http://www.nasm.us
          and refer BUILDING.md.''')
-    return '0'
+    return '0.0'

   match = re.match(r"NASM version ([2-9]\.[0-9][0-9]+)",
                    to_utf8(proc.communicate()[0]))
@@ -700,7 +700,7 @@ def get_nasm_version(asm):
   if match:
     return match.group(1)
   else:
-    return '0'
+    return '0.0'

 def get_llvm_version(cc):
   return get_version_helper(
@@ -733,7 +733,7 @@ def get_gas_version(cc):
     return match.group(1)
   else:
     warn('Could not recognize `gas`: ' + gas_ret)
-    return '0'
+    return '0.0'

 # Note: Apple clang self-reports as clang 4.2.0 and gcc 4.2.1.  It passes
 # the version check more by accident than anything else but a more rigorous
@@ -744,7 +744,7 @@ def check_compiler(o):
     if not options.openssl_no_asm and options.dest_cpu in ('x86', 'x64'):
       nasm_version = get_nasm_version('nasm')
       o['variables']['nasm_version'] = nasm_version
-      if nasm_version == 0:
+      if nasm_version == '0.0':
         o['variables']['openssl_no_asm'] = 1
     return

@@ -765,7 +765,7 @@ def check_compiler(o):
     # to a version that is not completely ancient.
     warn('C compiler too old, need gcc 4.2 or clang 3.2 (CC=%s)' % CC)

-  o['variables']['llvm_version'] = get_llvm_version(CC) if is_clang else 0
+  o['variables']['llvm_version'] = get_llvm_version(CC) if is_clang else '0.0'

   # Need xcode_version or gas_version when openssl asm files are compiled.
   if options.without_ssl or options.openssl_no_asm or options.shared_openssl:
diff --git a/configure.py.orig b/configure.py.orig
index 22861a1..5d57338 100755
--- a/configure.py.orig
+++ b/configure.py.orig
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
diff --git a/deps/openssl/openssl.gyp b/deps/openssl/openssl.gyp
index 60f6ee0..0ca7515 100644
--- a/deps/openssl/openssl.gyp
+++ b/deps/openssl/openssl.gyp
@@ -1,8 +1,8 @@
 {
   'variables': {
-    'gas_version%': 0,
-    'llvm_version%': 0,
-    'nasm_version%': 0,
+    'gas_version%': '0.0',
+    'llvm_version%': '0.0',
+    'nasm_version%': '0.0',
   },
   'targets': [
     {
diff --git a/tools/gyp/pylib/gyp/input.py b/tools/gyp/pylib/gyp/input.py
index a571b07..913f13d 100644
--- a/tools/gyp/pylib/gyp/input.py
+++ b/tools/gyp/pylib/gyp/input.py
@@ -2284,7 +2284,7 @@ def SetUpConfigurations(target, target_dict):
         merged_configurations[configuration])

   # Now drop all the abstract ones.
-  for configuration in target_dict['configurations'].keys():
+  for configuration in list(target_dict['configurations']):
     old_configuration_dict = target_dict['configurations'][configuration]
     if old_configuration_dict.get('abstract'):
       del target_dict['configurations'][configuration]
diff --git a/deps/v8/tools/gen-postmortem-metadata.py b/deps/v8/tools/gen-postmortem-metadata.py
index db4c6c236580..b5aba23220ba 100644
--- a/deps/v8/tools/gen-postmortem-metadata.py
+++ b/deps/v8/tools/gen-postmortem-metadata.py
@@ -624,7 +619,7 @@ def emit_set(out, consts):
 # Emit the whole output file.
 #
 def emit_config():
-        out = file(sys.argv[1], 'w');
+        out = open(sys.argv[1], 'w');

         out.write(header);

@@ -653,9 +653,7 @@ def emit_config():

         out.write('/* class type information */\n');
         consts = [];
-        keys = typeclasses.keys();
-        keys.sort();
-        for typename in keys:
+        for typename in sorted(typeclasses):
                 klass = typeclasses[typename];
                 consts.append({
                     'name': 'type_%s__%s' % (klass, typename),
@@ -666,9 +664,7 @@ def emit_config():

         out.write('/* class hierarchy information */\n');
         consts = [];
-        keys = klasses.keys();
-        keys.sort();
-        for klassname in keys:
+        for klassname in sorted(klasses):
                 pklass = klasses[klassname]['parent'];
                 bklass = get_base_class(klassname);
                 if (bklass != 'Object'):
diff --git a/node.gyp b/node.gyp
index e50a284..36559f1 100644
--- a/node.gyp
+++ b/node.gyp
@@ -665,6 +665,8 @@
           'action_name': 'node_js2c',
           'process_outputs_as_sources': 1,
           'inputs': [
+            # Put the code first so it's a dependency and can be used for invocation.
+            'tools/js2c.py',
             '<@(library_files)',
             'config.gypi',
             'tools/check_macros.py'
@@ -687,9 +689,8 @@
             }]
           ],
           'action': [
-            'python', 'tools/js2c.py',
-            '<@(_outputs)',
-            '<@(_inputs)',
+            'python', '<@(_inputs)',
+            '--target', '<@(_outputs)',
           ],
         },
       ],
diff --git a/tools/js2c.py b/tools/js2c.py
index 7dd77cb..1346b2a 100755
--- a/tools/js2c.py
+++ b/tools/js2c.py
@@ -27,49 +27,36 @@
 # (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 # OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

-# This is a utility for converting JavaScript source code into C-style
-# char arrays. It is used for embedded JavaScript code in the V8
-# library.
-
+"""
+This is a utility for converting JavaScript source code into uint16_t[],
+that are used for embedding JavaScript code into the Node.js binary.
+"""
+import argparse
 import os
 import re
-import sys
-import string
-import hashlib
-
-try:
-    xrange          # Python 2
-except NameError:
-    xrange = range  # Python 3
-
-
-def ToCArray(elements, step=10):
-  slices = (elements[i:i+step] for i in xrange(0, len(elements), step))
-  slices = map(lambda s: ','.join(str(x) for x in s), slices)
-  return ',\n'.join(slices)
-
-
-def ToCString(contents):
-  return ToCArray(map(ord, contents), step=20)
-
+import functools
+import codecs

 def ReadFile(filename):
-  file = open(filename, "rt")
-  try:
-    lines = file.read()
-  finally:
-    file.close()
-  return lines
+  if is_verbose:
+    print(filename)
+  with codecs.open(filename, "r", "utf-8") as f:
+    lines = f.read()
+    return lines
+

+def ReadMacroFiles(filenames):
+  """

-def ReadLines(filename):
+  :rtype: List(str)
+  """
   result = []
-  for line in open(filename, "rt"):
-    if '#' in line:
-      line = line[:line.index('#')]
-    line = line.strip()
-    if len(line) > 0:
-      result.append(line)
+  for filename in filenames:
+    with open(filename, "rt") as f:
+      # strip python-like comments and whitespace padding
+      lines = [line.split('#')[0].strip() for line in f]
+      # filter empty lines
+      result.extend(filter(bool, lines))
   return result


@@ -82,6 +69,7 @@ def ExpandConstants(lines, constants):
 def ExpandMacros(lines, macros):
   def expander(s):
     return ExpandMacros(s, macros)
+
   for name, macro in macros.items():
     name_pattern = re.compile("\\b%s\\(" % name)
     pattern_match = name_pattern.search(lines, 0)
@@ -94,13 +82,15 @@ def ExpandMacros(lines, macros):
       last_match = end
       arg_index = [0]  # Wrap state into array, to work around Python "scoping"
       mapping = {}
-      def add_arg(str):
+
+      def add_arg(s):
         # Remember to expand recursively in the arguments
         if arg_index[0] >= len(macro.args):
           return
-        replacement = expander(str.strip())
+        replacement = expander(s.strip())
         mapping[macro.args[arg_index[0]]] = replacement
         arg_index[0] += 1
+
       while end < len(lines) and height > 0:
         # We don't count commas at higher nesting levels.
         if lines[end] == ',' and height == 1:
@@ -112,10 +102,11 @@ def ExpandMacros(lines, macros):
           height = height - 1
         end = end + 1
       # Remember to add the last match.
-      add_arg(lines[last_match:end-1])
-      if arg_index[0] < len(macro.args) -1:
+      add_arg(lines[last_match:end - 1])
+      if arg_index[0] < len(macro.args) - 1:
         lineno = lines.count(os.linesep, 0, start) + 1
-        raise Exception('line %s: Too few arguments for macro "%s"' % (lineno, name))
+        raise Exception(
+          'line %s: Too few arguments for macro "%s"' % (lineno, name))
       result = macro.expand(mapping)
       # Replace the occurrence of the macro with the expansion
       lines = lines[:start] + result + lines[end:]
@@ -127,34 +118,39 @@ class TextMacro:
   def __init__(self, args, body):
     self.args = args
     self.body = body
+
   def expand(self, mapping):
     result = self.body
     for key, value in mapping.items():
-        result = result.replace(key, value)
+      result = result.replace(key, value)
     return result

+
 class PythonMacro:
   def __init__(self, args, fun):
     self.args = args
     self.fun = fun
+
   def expand(self, mapping):
     args = []
     for arg in self.args:
       args.append(mapping[arg])
     return str(self.fun(*args))

+
 CONST_PATTERN = re.compile('^const\s+([a-zA-Z0-9_]+)\s*=\s*([^;]*);$')
 MACRO_PATTERN = re.compile('^macro\s+([a-zA-Z0-9_]+)\s*\(([^)]*)\)\s*=\s*([^;]*);$')
 PYTHON_MACRO_PATTERN = re.compile('^python\s+macro\s+([a-zA-Z0-9_]+)\s*\(([^)]*)\)\s*=\s*([^;]*);$')

-def ReadMacros(lines):
-  constants = { }
-  macros = { }
+
+def ReadMacros(macro_files):
+  lines = ReadMacroFiles(macro_files)
+  constants = {}
+  macros = {}
   for line in lines:
-    hash = line.find('#')
-    if hash != -1: line = line[:hash]
-    line = line.strip()
-    if len(line) is 0: continue
+    line = line.split('#')[0].strip()
+    if len(line) == 0:
+      continue
     const_match = CONST_PATTERN.match(line)
     if const_match:
       name = const_match.group(1)
@@ -164,202 +160,194 @@ def ReadMacros(lines):
       macro_match = MACRO_PATTERN.match(line)
       if macro_match:
         name = macro_match.group(1)
-        args = map(string.strip, macro_match.group(2).split(','))
+        args = [p.strip() for p in macro_match.group(2).split(',')]
         body = macro_match.group(3).strip()
         macros[name] = TextMacro(args, body)
       else:
         python_match = PYTHON_MACRO_PATTERN.match(line)
         if python_match:
           name = python_match.group(1)
-          args = map(string.strip, python_match.group(2).split(','))
+          args = [p.strip() for p in macro_match.group(2).split(',')]
           body = python_match.group(3).strip()
           fun = eval("lambda " + ",".join(args) + ': ' + body)
           macros[name] = PythonMacro(args, fun)
         else:
           raise Exception("Illegal line: " + line)
-  return (constants, macros)
+  return constants, macros


 TEMPLATE = """
-#include "node.h"
-#include "node_javascript.h"
-#include "v8.h"
-#include "env.h"
 #include "env-inl.h"
+#include "node_native_module.h"
+#include "node_internals.h"

 namespace node {{

-namespace {{
-
-{definitions}
+namespace native_module {{

-}}  // anonymous namespace
+{0}

-v8::Local<v8::String> NodePerContextSource(v8::Isolate* isolate) {{
-  return internal_per_context_value.ToStringChecked(isolate);
+void NativeModuleLoader::LoadJavaScriptSource() {{
+  {1}
 }}

-v8::Local<v8::String> LoadersBootstrapperSource(Environment* env) {{
-  return internal_bootstrap_loaders_value.ToStringChecked(env->isolate());
+UnionBytes NativeModuleLoader::GetConfig() {{
+  return UnionBytes(config_raw, {2});  // config.gypi
 }}

-v8::Local<v8::String> NodeBootstrapperSource(Environment* env) {{
-  return internal_bootstrap_node_value.ToStringChecked(env->isolate());
-}}
-
-void DefineJavaScript(Environment* env, v8::Local<v8::Object> target) {{
-  {initializers}
-}}
-
-void DefineJavaScriptHash(Environment* env, v8::Local<v8::Object> target) {{
-  {hash_initializers}
-}}
+}}  // namespace native_module

 }}  // namespace node
 """

 ONE_BYTE_STRING = """
-static const uint8_t raw_{var}[] = {{ {data} }};
-static struct : public v8::String::ExternalOneByteStringResource {{
-  const char* data() const override {{
-    return reinterpret_cast<const char*>(raw_{var});
-  }}
-  size_t length() const override {{ return arraysize(raw_{var}); }}
-  void Dispose() override {{ /* Default calls `delete this`. */ }}
-  v8::Local<v8::String> ToStringChecked(v8::Isolate* isolate) {{
-    return v8::String::NewExternalOneByte(isolate, this).ToLocalChecked();
-  }}
-}} {var};
+static const uint8_t {0}[] = {{
+{1}
+}};
 """

 TWO_BYTE_STRING = """
-static const uint16_t raw_{var}[] = {{ {data} }};
-static struct : public v8::String::ExternalStringResource {{
-  const uint16_t* data() const override {{ return raw_{var}; }}
-  size_t length() const override {{ return arraysize(raw_{var}); }}
-  void Dispose() override {{ /* Default calls `delete this`. */ }}
-  v8::Local<v8::String> ToStringChecked(v8::Isolate* isolate) {{
-    return v8::String::NewExternalTwoByte(isolate, this).ToLocalChecked();
-  }}
-}} {var};
+static const uint16_t {0}[] = {{
+{1}
+}};
 """

-INITIALIZER = """\
-CHECK(target->Set(env->context(),
-                  {key}.ToStringChecked(env->isolate()),
-                  {value}.ToStringChecked(env->isolate())).FromJust());
-"""
+INITIALIZER = 'source_.emplace("{0}", UnionBytes{{{1}, {2}}});'

-HASH_INITIALIZER = """\
-CHECK(target->Set(env->context(),
-                  FIXED_ONE_BYTE_STRING(env->isolate(), "{key}"),
-                  FIXED_ONE_BYTE_STRING(env->isolate(), "{value}")).FromJust());
-"""
+CONFIG_GYPI_ID = 'config_raw'

-DEPRECATED_DEPS = """\
-'use strict';
-process.emitWarning(
-  'Requiring Node.js-bundled \\'{module}\\' module is deprecated. Please ' +
-  'install the necessary module locally.', 'DeprecationWarning', 'DEP0084');
-module.exports = require('internal/deps/{module}');
-"""
+SLUGGER_RE =re.compile('[.\-/]')

+is_verbose = False

-def Render(var, data):
-  # Treat non-ASCII as UTF-8 and convert it to UTF-16.
-  if any(ord(c) > 127 for c in data):
+def GetDefinition(var, source, step=30):
+  template = ONE_BYTE_STRING
+  code_points = [ord(c) for c in source]
+  if any(c > 127 for c in code_points):
     template = TWO_BYTE_STRING
-    data = map(ord, data.decode('utf-8').encode('utf-16be'))
-    data = [data[i] * 256 + data[i+1] for i in xrange(0, len(data), 2)]
-    data = ToCArray(data)
-  else:
-    template = ONE_BYTE_STRING
-    data = ToCString(data)
-  return template.format(var=var, data=data)
-
-
-def JS2C(source, target):
-  modules = []
-  consts = {}
-  macros = {}
-  macro_lines = []
-
-  for s in source:
-    if (os.path.split(str(s))[1]).endswith('macros.py'):
-      macro_lines.extend(ReadLines(str(s)))
-    else:
-      modules.append(s)
-
+    # Treat non-ASCII as UTF-8 and encode as UTF-16 Little Endian.
+    encoded_source = bytearray(source, 'utf-16le')
+    code_points = [
+      encoded_source[i] + (encoded_source[i + 1] * 256)
+      for i in range(0, len(encoded_source), 2)
+    ]
+
+  # For easier debugging, align to the common 3 char for code-points.
+  elements_s = ['%3s' % x for x in code_points]
+  # Put no more then `step` code-points in a line.
+  slices = [elements_s[i:i + step] for i in range(0, len(elements_s), step)]
+  lines = [','.join(s) for s in slices]
+  array_content = ',\n'.join(lines)
+  definition = template.format(var, array_content)
+
+  return definition, len(code_points)
+
+
+def AddModule(filename, consts, macros, definitions, initializers):
+  code = ReadFile(filename)
+  code = ExpandConstants(code, consts)
+  code = ExpandMacros(code, macros)
+  name = NormalizeFileName(filename)
+  slug = SLUGGER_RE.sub('_', name)
+  var = slug + '_raw'
+  definition, size = GetDefinition(var, code)
+  initializer = INITIALIZER.format(name, var, size)
+  definitions.append(definition)
+  initializers.append(initializer)
+
+def NormalizeFileName(filename):
+  split = filename.split(os.path.sep)
+  if split[0] == 'deps':
+    split = ['internal'] + split
+  else:  # `lib/**/*.js` so drop the 'lib' part
+    split = split[1:]
+  if len(split):
+    filename = '/'.join(split)
+  return os.path.splitext(filename)[0]
+
+
+def JS2C(source_files, target):
   # Process input from all *macro.py files
-  (consts, macros) = ReadMacros(macro_lines)
+  consts, macros = ReadMacros(source_files['.py'])

   # Build source code lines
   definitions = []
   initializers = []
-  hash_initializers = [];
-
-  for name in modules:
-    lines = ReadFile(str(name))
-    lines = ExpandConstants(lines, consts)
-    lines = ExpandMacros(lines, macros)
-
-    deprecated_deps = None
-
-    # On Windows, "./foo.bar" in the .gyp file is passed as "foo.bar"
-    # so don't assume there is always a slash in the file path.
-    if '/' in name or '\\' in name:
-      split = re.split('/|\\\\', name)
-      if split[0] == 'deps':
-        if split[1] == 'node-inspect' or split[1] == 'v8':
-          deprecated_deps = split[1:]
-        split = ['internal'] + split
-      else:
-        split = split[1:]
-      name = '/'.join(split)
-
-    # if its a gypi file we're going to want it as json
-    # later on anyway, so get it out of the way now
-    if name.endswith(".gypi"):
-      lines = re.sub(r'#.*?\n', '', lines)
-      lines = re.sub(r'\'', '"', lines)
-    name = name.split('.', 1)[0]
-    var = name.replace('-', '_').replace('/', '_')
-    key = '%s_key' % var
-    value = '%s_value' % var
-    hash_value = hashlib.sha256(lines).hexdigest()
-
-    definitions.append(Render(key, name))
-    definitions.append(Render(value, lines))
-    initializers.append(INITIALIZER.format(key=key, value=value))
-    hash_initializers.append(HASH_INITIALIZER.format(key=name, value=hash_value))
-
-    if deprecated_deps is not None:
-      name = '/'.join(deprecated_deps)
-      name = name.split('.', 1)[0]
-      var = name.replace('-', '_').replace('/', '_')
-      key = '%s_key' % var
-      value = '%s_value' % var
-
-      definitions.append(Render(key, name))
-      definitions.append(Render(value, DEPRECATED_DEPS.format(module=name)))
-      initializers.append(INITIALIZER.format(key=key, value=value))
-      hash_initializers.append(HASH_INITIALIZER.format(key=name, value=hash_value))
+
+  for filename in source_files['.js']:
+    AddModule(filename, consts, macros, definitions, initializers)
+
+  config_def, config_size = handle_config_gypi(source_files['config.gypi'])
+  definitions.append(config_def)

   # Emit result
-  output = open(str(target[0]), "w")
-  output.write(TEMPLATE.format(definitions=''.join(definitions),
-                               initializers=''.join(initializers),
-                               hash_initializers=''.join(hash_initializers)))
-  output.close()
+  definitions = ''.join(definitions)
+  initializers = '\n  '.join(initializers)
+  out = TEMPLATE.format(definitions, initializers, config_size)
+  write_if_chaged(out, target)
+
+
+def handle_config_gypi(config_filename):
+  # if its a gypi file we're going to want it as json
+  # later on anyway, so get it out of the way now
+  config = ReadFile(config_filename)
+  config = jsonify(config)
+  config_def, config_size = GetDefinition(CONFIG_GYPI_ID, config)
+  return config_def, config_size
+
+
+def jsonify(config):
+  # 1. string comments
+  config = re.sub(r'#.*?\n', '', config)
+  # 3. normalize string literals from ' into "
+  config = re.sub('\'', '"', config)
+  # 2. turn pseudo-booleans strings into Booleans
+  config = re.sub('"true"', 'true', config)
+  config = re.sub('"false"', 'false', config)
+  return config
+
+
+def write_if_chaged(content, target):
+  if os.path.exists(target):
+    with open(target, 'rt') as existing:
+      old_content = existing.read()
+  else:
+    old_content = ''
+  if old_content == content:
+    return
+  with open(target, "wt") as output:
+    output.write(content)
+
+
+def SourceFileByExt(files_by_ext, filename):
+  """
+  :type files_by_ext: dict
+  :type filename: str
+  :rtype: dict
+  """
+  ext = os.path.splitext(filename)[-1]
+  files_by_ext.setdefault(ext, []).append(filename)
+  return files_by_ext

 def main():
-  natives = sys.argv[1]
-  source_files = sys.argv[2:]
-  if source_files[-2] == '-t':
-    global TEMPLATE
-    TEMPLATE = source_files[-1]
-    source_files = source_files[:-2]
-  JS2C(source_files, [natives])
+  parser = argparse.ArgumentParser(
+    description='Convert code files into `uint16_t[]`s',
+    fromfile_prefix_chars='@'
+  )
+  parser.add_argument('--target', help='output file')
+  parser.add_argument('--verbose', action='store_true', help='output file')
+  parser.add_argument('sources', nargs='*', help='input files')
+  options = parser.parse_args()
+  global is_verbose
+  is_verbose = options.verbose
+  source_files = functools.reduce(SourceFileByExt, options.sources, {})
+  # Should have exactly 3 types: `.js`, `.py`, and `.gypi`
+  assert len(source_files) == 3
+  # Currently config.gypi is the only `.gypi` file allowed
+  assert source_files['.gypi'] == ['config.gypi']
+  source_files['config.gypi'] = source_files.pop('.gypi')[0]
+  JS2C(source_files, options.target)
+

 if __name__ == "__main__":
   main()
