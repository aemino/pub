// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS d.file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';

import '../../descriptor.dart' as d;
import '../../serve/utils.dart';
import '../../test_pub.dart';

main() {
  test("allows a single string as the asset to exclude", () async {
    await serveBarback();

    await d.dir(appPath, [
      d.pubspec({
        "name": "myapp",
        "transformers": [
          {
            "myapp/src/transformer": {"\$exclude": "web/foo.txt"}
          }
        ],
        "dependencies": {"barback": "any"}
      }),
      d.dir("lib", [
        d.dir("src", [d.file("transformer.dart", REWRITE_TRANSFORMER)])
      ]),
      d.dir("web", [
        d.file("foo.txt", "foo"),
        d.file("bar.txt", "bar"),
        d.dir("sub", [
          d.file("foo.txt", "foo"),
        ])
      ])
    ]).create();

    await pubGet();
    await pubServe();
    await requestShould404("foo.out");
    await requestShouldSucceed("sub/foo.out", "foo.out");
    await requestShouldSucceed("bar.out", "bar.out");
    await endPubServe();
  });
}
