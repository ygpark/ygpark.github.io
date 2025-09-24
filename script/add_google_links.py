# filename: add_google_links.py
import re
import sys
from pathlib import Path
from urllib.parse import quote_plus

def convert_headings_to_links(md_text: str) -> str:
    """
    ## 제목  ->  ## [제목](<https://www.google.com/search?q=제목>)
    제목이 넘버링되어 있는 경우 숫자를 제거합니다.
    예: ## 1. 제목  ->  ## [제목](<https://www.google.com/search?q=제목>)
    """

    def replacer(match):
        title = match.group(1).strip()
        # '**' 굵게 마크다운 문법 제거
        title_no_bold = title.replace('**', '')
        # 제목 앞의 넘버링 제거 (예: "1. ", "2) ", "3-", "4." 등)
        title_clean = re.sub(r'^\d+[\.\)\-\s]+', '', title_no_bold).strip()
        query = quote_plus(title_clean)
        return f"## [{title}](<https://www.google.com/search?q={query}>)"

    # ^## (.*)$ : ## 뒤의 내용을 캡처 (단, 이미 링크가 걸린 경우는 제외)
    # 이미 링크가 걸린 제목(## [...]로 시작)은 건드리지 않음
    return re.sub(r'^## (?!\[)(.+)$', replacer, md_text, flags=re.MULTILINE)

def show_help():
    """도움말 출력"""
    help_text = """
Google 검색 링크 추가 도구
=======================

마크다운 파일의 ## 제목을 Google 검색 링크로 자동 변환합니다.

사용법:
    python add_google_links.py [파일1.md] [파일2.md] ...
    python add_google_links.py *.md
    python add_google_links.py content/posts/*.md

옵션:
    --help, -h    이 도움말을 표시합니다

예시:
    # 단일 파일 처리
    python add_google_links.py post.md
    
    # 여러 파일 처리
    python add_google_links.py file1.md file2.md file3.md
    
    # 모든 .md 파일 처리
    python add_google_links.py *.md
    
    # 특정 폴더의 모든 .md 파일 처리
    python add_google_links.py content/posts/*.md

변환 예시:
    변환 전: ## 1. 경제 성장률 발표
    변환 후: ## [1. 경제 성장률 발표](<https://www.google.com/search?q=경제 성장률 발표>)

주의사항:
    - 이미 링크가 걸린 제목(## [제목] 형태)은 변경하지 않습니다
    - .md 확장자가 아닌 파일은 건너뜁니다
    - 변경사항이 있는 파일만 저장됩니다
"""
    print(help_text)

def main():
    # 도움말 옵션 확인
    if len(sys.argv) < 2 or '--help' in sys.argv or '-h' in sys.argv:
        show_help()
        sys.exit(0)

    # 여러 파일 처리
    file_paths = sys.argv[1:]
    processed_count = 0
    
    for file_arg in file_paths:
        input_file = Path(file_arg)
        
        # 파일이 존재하지 않으면 건너뛰기
        if not input_file.exists():
            print(f"파일을 찾을 수 없습니다: {input_file}")
            continue
            
        # .md 파일이 아니면 건너뛰기
        if input_file.suffix.lower() != '.md':
            print(f"마크다운 파일이 아닙니다: {input_file}")
            continue
            
        try:
            text = input_file.read_text(encoding="utf-8")
            new_text = convert_headings_to_links(text)
            
            # 변경사항이 있는 경우에만 파일을 저장
            if text != new_text:
                input_file.write_text(new_text, encoding="utf-8")
                print(f"변환 완료: {input_file}")
                processed_count += 1
            else:
                print(f"변경사항 없음: {input_file}")
        except Exception as e:
            print(f"파일 처리 중 오류 발생 ({input_file}): {e}")
            
    print(f"\n총 {processed_count}개 파일 처리 완료!")

if __name__ == "__main__":
    main()
