# filename: add_google_links.py
import re
import sys
from pathlib import Path
from urllib.parse import quote_plus

def convert_headings_to_links(md_text: str) -> str:
    """
    ### 제목  ->  ### [제목](<https://www.google.com/search?q=제목>)
    제목이 넘버링되어 있는 경우 숫자를 제거합니다.
    예: ### 1. 제목  ->  ### [제목](<https://www.google.com/search?q=제목>)
    """

    def replacer(match):
        title = match.group(1).strip()
        # 제목 앞의 넘버링 제거 (예: "1. ", "2) ", "3-", "4." 등)
        title_without_numbering = re.sub(r'^\d+[\.\)\-\s]+', '', title).strip()
        query = quote_plus(title_without_numbering)
        return f"### [{title}](<https://www.google.com/search?q={query}>)"

    # ^### (.*)$ : ### 뒤의 내용을 캡처 (단, 이미 링크가 걸린 경우는 제외)
    # 이미 링크가 걸린 제목(### [...]로 시작)은 건드리지 않음
    return re.sub(r'^### (?!\[)(.+)$', replacer, md_text, flags=re.MULTILINE)

def main():
    if len(sys.argv) < 2:
        print("사용법: python add_google_links.py input.md [output.md]")
        sys.exit(1)

    input_file = Path(sys.argv[1])
    output_file = Path(sys.argv[2]) if len(sys.argv) > 2 else input_file

    text = input_file.read_text(encoding="utf-8")
    new_text = convert_headings_to_links(text)
    output_file.write_text(new_text, encoding="utf-8")

    print(f"변환 완료! 결과 저장: {output_file}")

if __name__ == "__main__":
    main()
