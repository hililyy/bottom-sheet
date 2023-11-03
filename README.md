# bottom-sheet
- [PanModal](https://github.com/slackhq/PanModal)을 직접 만들어 보았습니다.
- [링크](https://velog.io/@dd3557/iOS-14-Auto-Layout%EC%9D%84-%EC%9D%B4%EC%9A%A9%ED%95%98%EC%97%AC-%ED%8E%98%EC%9D%B4%EC%8A%A4%EB%B6%81%EC%9D%98-Bottom-Sheet%EC%9D%84-%EB%A7%8C%EB%93%A4%EC%96%B4%EB%B3%B4%EC%9E%90-Part-1)를 참고하여 리팩토링하여 완성하였습니다.


![bottomsheet](https://github.com/hililyy/bottom-sheet/assets/76806444/7df25f75-2038-4b1e-9d2c-560bb1a32815)


# 기능
- 유저가 스크롤 했을 때  하단, 중단, 상단 중 가까운 곳을 계산하여 뷰를 나타냄
- 바텀시트를 내릴 수록 배경의 alpha값 변화
- 유저의 바텀시트 상하단 스크롤 속도를 감지하여 바텀시트를 전체 화면 또는 사라지도록 구성
- 원하는 콘텐츠만 바텀시트를 띄울 뷰 컨트롤러에서 전달하여 사용자가 쉽게 사용하도록 구성
