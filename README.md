# Toko Games

GitHub Pages向けの静的公式サイトです。HTMLとCSSだけで表示します。

- トップ：`/`
- めぐポ プライバシーポリシー：`/megupo/privacy/`
- めぐポ 利用規約：`/megupo/terms/`
- 問い合わせ先：トップの `#contact`

プロジェクトサイトではURLの先頭にリポジトリ名が付きます。全リンクを相対パスにし、`tokogames-site` 配下でも動作する構造です。

原稿は `content/` にあります。確定本文の変更が必要なときだけ更新し、PowerShellで `./tools/build.ps1` を実行してHTMLへ反映します。原稿の制定日は2026年10月20日です。

JavaScript、広告、解析、外部フォント、Cookie・ストレージ処理は導入していません。
GitHub Pagesの公開元は `main` ブランチのルートを指定します。`.nojekyll` によりビルド不要の静的ファイルを公開します。
