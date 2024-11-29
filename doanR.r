---
title: "R Notebook"
output: html_notebook
---

    Chương 7: Phân loại mẫu Microarray

 Nghiên cứu tình huống thứ tư thuộc lĩnh vực tin sinh học. Cụ thể, chúng tôi sẽ giải quyết vấn để phân loại các mẫu microarray thành một tập hợp các lớp thay thế. Cụ thể hơn, với một đầu do microarray mô tả mức độ biểu hiện gen của bệnh nhân, chúng tôi hưởng đến việc phân loại bệnh nhân này thành một tập hợp các đột biến gen được xác định trước của bệnh bạch cầu lymphoblastic cấp tỉnh. Nghiên cứu tình huống này giải quyết một số chủ đề khai thác dữ liệu mới. 
 Trọng tâm chính, xét đến các đặc điểm của loại tập dữ liệu này, là lựa chọn tính năng, tức là cách giảm số lượng tính năng mô tả từng quan sát. Trong cách tiếp cận của chúng tôi đối với ứng dụng cụ thể này, chúng tôi sẽ minh họa một số phương pháp chung để lựa chọn tính năng. Các chủ đề khai thác dữ liệu mới khác được giải quyết trong chương này bao gồm bộ phân loại k-lảng giềng gần nhất, ước tinh bootstrap và một số biến thể mới của mô hình tổng hợp.

7.1 Mô tả vấn đề và mục tiêu
Tin sinh học là một trong những lĩnh vực ứng dụng chính của R. Thậm chí còn có một dự án liên quan dựa trên R, với mục tiêu cung cấp một bộ công cụ phân tích lớn cho lĩnh vực này. Dự án có tên là Bioconductor. Nghiên cứu tình huống này sẽ sử dụng các công cụ do dự án này cung cấp để giải quyết vấn đề phân loại cỏ giảm sắt.

7.1.1 Tóm tắt về thí nghiệm Microarray
Một trong những khó khăn chính mà những người có nền tảng ngoài khoa học sinh học phải đối mặt là số lượng lớn các thuật ngữ "mới" được sử dụng trong tin sinh học. Trong phần nền tảng rất ngắn gọn này, chúng tôi cố gắng giới thiệu cho người đọc một số "thuật ngữ chuyên ngành" trong lĩnh vực này và cũng cung cấp một số bản đồ đến thuật ngữ khai thác dữ liệu "chuẩn" hơn. Phân tích biểu hiện gen khác biệt là một trong những ứng dụng chính của DNA mi-vim thí nghiệm croarray.
Mảng biểu hiện gen cho phép chúng ta mô tả một tập hợp các mẫu (ví dụ: cả thể) theo mức độ biểu hiện của chúng trên một tập hợp lớn các gen. Trong lĩnh vực này, một mẫu do đó là một quan sát (trường hợp) của một số hiện tượng đang được nghiên cứu. Các thí nghiệm mảng vi mô là phương tiện được sử dụng để đo một tập hợp các "biến" cho các quan sát này. Các biển ở đây là một tập hợp lớn các gen. Đối với mỗi biến (gen), các thí nghiệm này đo một giá trị biểu hiện. 
Tóm lại, một tập dữ liệu được hình thành bởi một tập hợp các mẫu (các trường hợp) mà chúng ta đã đo mức độ biểu hiện trên một tập hợp lớn các gen (các biến). Nếu các mẫu này có một số trạng thái bệnh liên quan đến chúng, chúng ta có thể thử xấp xỉ hảm chưa biết để ảnh xạ mức độ biểu hiện gen thành các trạng thái bệnh. Hàm này có thể được xấp xỉ bằng cách sử dụng một tập hợp các mẫu đã phân tích trước đó. Đây là một ví dụ về các tác vụ phân loại được giám sát, 
trong đó biến mục tiêu là loại bệnh. Các quan sát Khai thác dữ liệu với F: Học tập với các nghiên cứu tình huống trong bài toán này là các mẫu (microarray, cả thể), và các biến dự bảo là các gen mà chúng ta đo giá trị (mức độ biểu hiện) bằng cách sử dụng một thí nghiệm microarray. Giả thuyết chính ở đây là các loại bệnh khác nhau có thể liên quan đến các kiểu biểu hiện gen khác nhau và hơn nữa, bằng cách đo các kiểu này bằng microarray, chúng ta có thể dự đoán chính xác loại bệnh của một cá thể.
Có một số loại công nghệ được tạo ra với mục tiêu thu được mức độ biểu hiện gen trên một số mẫu. Mảng oligonucleotide ngắn là một ví dụ về các công nghệ này. Đầu ra của chip digonucleotide là một hình ảnh sau một số bước tiến xử lý có thể được ảnh xạ thành một tập hợp các mức độ biểu hiện gen cho một tập hợp gen khá lớn. Dự án bioconductor có một số gói R dành
riêng cho các bước tiến xử lý này liên quan đến các vấn đề như phân tích hình ảnh thu được từ chip
oligonucleotide, các tác vụ chuẩn hóa và một số bước khác cần thiết cho đến khi chúng ta đạt được một tập hợp điểm biểu hiện gen. Trong nghiên cứu điển hình này, chúng tôi không đề cập đến các bước ban đầu này. Người đọc quan tâm được hướng dẫn đến một số nguồn thông tin có sẵn tại trang web bioconductor cũng như một số cuốn sách (ví dụ: Hahne et al. (2008)).
Trong nghiên cứu tình huống này, điểm khởi đầu của chúng ta sẽ là một ma trận các mức
biểu hiện gen thu được từ các bước tiền xử lý này. Đây là thông tin về các biến dự báo cho các quan sát của chúng ta. Như chúng ta sẽ thấy, thường có nhiều biến dự báo được đo lường hơn các mẫu; nghĩa là chúng ta có nhiều biến dự bảo hơn các quan sát. Đây là một đặc điểm điển hinh của các tập dữ liệu mảng vi mô. Một đặc điểm khác của các ma trận biểu hiện này là chúng có vẻ như được chuyển vị khi so sánh với "chuẩn" của các tập dữ liệu. Điều này có nghĩa là các hàng sẽ biểu thị các biến dự báo (tức là các gen),
trong khi các cột là các quan sát (các mẫu). Đối với mỗi mẫu, chúng ta cũng sẽ cần phân loại liên quan. Trong trường hợp của chúng ta, đây sẽ là một loại đột biển liên quan của một căn bệnh. Cũng có thể có thông tin về các biến phụ trợ khác (ví dụ: giới tính và độ tuổi của những cá nhân được lấy mẫu, v.v.).

7.1.2 Bộ dữ liệu TẤT CẢ
Bộ dữ liệu chúng tôi sẽ sử dụng xuất phát từ một nghiên cứu về bệnh bạch cầu lymphoblastic cấp tỉnh (Chiaretti và cộng sự, 2004; Li, 2009). Dữ liệu bao gồm các mẫu microarray từ 128 cá nhân mắc loại bệnh này. Trên thực tế, có hai loại khối u khác nhau trong số các mẫu này: T-cell ALL (33 mẫu) và B-cell ALL (95 mẫu). Chúng tôi sẽ tập trung nghiên cứu của mình vào dữ liệu liên quan đến các mẫu ALL tế bào B. Ngay cả trong nhóm mẫu sau này, chúng tôi vẫn có thể phân biệt các loại đột biến khác nhau. 
Cụ thể là ALL1/AF4, BCRIABL, E2A/PBX1, p15/p16 và cả những cá nhân không có bất thường về tế bào học. Trong phân tích các mẫu ALL tế bào B, chúng tôi sẽ loại bỏ đột biến p15/p16 vị chúng tôi chỉ có một mẫu. Mục tiêu mô hình hóa của chúng tối là có thể dự đoán loại đột biến của một cá nhân dựa trên xét nghiệm mảng vi mô của họ. Với biến mục tiêu là danh nghĩa với 4 giá trị có thể, chúng tôi đang đối mặt với nhiệm vụ phân loại có giảm sát.

7.2 Dữ liệu có sẵn
Bộ dữ liệu ALL là một phần của bộ gói bioconductor. Để sử dụng, chúng ta cần cải đặt ít nhất một bộ gói cơ bản từ bioconductor. Chúng tôi không đưa bộ dữ liệu vào gói sách của minh vì bộ dữ liệu đã là một phần của "universe" R. Để cài đặt một bộ các gói bioconductor cơ bản và tập dữ liệu ALL, chúng ta cần thực hiện các hướng dẫn sau đây với giả định rằng chúng ta có kết nối Internet đang hoạt động.

> source("http://bioconductor.org/bioclite.R")
> bioclite() bioclite("ALL")

Việc này chỉ cần thực hiện lần đầu tiên. Sau khi bạn đã cài đặt các gói này, nếu bạn muốn sử dụng tập dữ liệu, bạn chỉ cần thực hiện:

> library(Biobase)
> library(ALL)
> data (ALL)
Các hướng dẫn này tải các gói Biobase (Gentleman và cộng sự, 2004) và ALL (Gentleman và cộng sự, 2010). Sau đó, chúng tôi tải tập dữ liệu ALL, tạo ra một đối tượng thuộc lớp đặc biệt (ExpressionSet) do Bioconductor định nghĩa. Lớp đối tượng này chứa thông tin quan trọng liên quan đến tập dữ liệu microarray. Có một số hàm liên quan để xử lý loại đối tượng này. Nếu bạn hỏi R về nội dung của đối tượng ALL, bạn sẽ nhận được thông tin sau:

> ALL
ExpressionSet (storageMode: lockedEnvironment).
assayData: 12625 features, 128 samples
element names: expra
protocolData: none
phenoData
samplellanes: 01005 01010... LAL4 (128 total)
varLabels: cod diagnosis... date last seen (21 total)
varMetadata: labelDescription
featureData: none
experimentData: use 'experimentData(object)'
pubMedIda: 14684422 16243790
Annotation: hgu95av2

Thông tin được chia thành nhiều nhóm. Đầu tiên, chúng ta có dữ liệu xét nghiệm với ma trận mức độ biểu hiện gen. Đối với tập dữ liệu này, chúng ta có 12.625 gen và 128 mẫu. Đối tượng cũng chứa nhiều siêu dữ liệu về các mẫu của thí nghiệm. Điều này bao gồm phần phenoData với thông tin về tên mẫu và một số biến thể liên quan. Nó cũng bao gồm thông tin về các tính năng (tức là gen) cũng như chú thích của các gen từ cơ sở dữ liệu y sinh học. Cuối cùng, đối tượng cũng chứa thông tin mô tả thí nghiệm.
Có một số hàm giúp truy cập thông tin trong các đối tượng Expression-Set. Chúng tôi đưa ra một số ví dụ dưới đây. Chúng tôi bắt đầu bằng cách lấy một số thông tin về các biến phụ thuộc liên quan đến từng mẫu:

> pD <- phanoData (ALL)
> varMetadata(pD)
cod
diagnosia
sex
age
BT
labelDescription Patient ID
Date of diagnosis Gender of the patient
Age of the patient at entry
does the patient have B-cell or T-cell ALL

remission,Complete remission(CR), refractory(REF) or NA. Derived from 
CR
date.cr,,,,,,Date complete remission if achieved
t(4;11),did the patient have t(4;11) translocation. Derived from citog
t(9;22),did the patient have t(9;22) translocation. Derived from citog
cyto.normal,Was cytogenetic test normal? Derived from citog
citog,,original cytogenetics data, deletions or t(4;11), t(9;22) status
mol.biol,,,molecular biology
fusion_protein,,,which of p190, p210 or p190/210 for bcr/abl
mdr,,,multi-drug resistant
ccr,Complete continuous remission? Derived from f.u
relapse,,Relapse? Derived from f.u
transplant,did the patient receive a bone marrow transplant? Derived from f.u
f.u,,follow up data available
date last seen,,date patient was last seen

table(ALL$ST)
B B1 B2 B3 B4 T T1 T2 T3 T4
5 19 36 23 12 5 1 15 10 2

table(ALL$mol.biol)
ALL1/AF4 BCR/ABL E2A/PBX1 NEG NUP-98 p15/p16
10 37 5 74 1 1

table(ALL$ST, ALL$mol.biol)
ALL1/AF4 BCR/ABL E2A/PBX1 NEG NUP-98 p15/p16
B      0       2        1   2      0       0
B1     10      1        0   8      0       0
B2     0       19       0   16     0       1
B3     0       8        1   14     0       0
B4     2       7        3   2      0       0
T      0       0        0   5      0       0
T1     0       0        0   1      0       0
T2     0       0        0   15     0       0  
T3     0       0        0   9      1       0
T4     0       0        0   2      0       0

Hai câu lệnh đầu tiên lấy tên và mô tả của các biến thể phụ trợ hiện có. Sau đó, chúng tôi lấy một số thông tin về sự phân bố của các mẫu trên hai biến thể phụ trợ chính: biến BT xác định loại bệnh bạch cầu lymphoblastic cấp tính và biến mol. bio mô tả bất thường về tế bào học được tìm thấy trên mỗi mẫu (NEG biểu thị không có bất thường).

Chúng tôi cũng có thể lấy một số thông tin về gen và mẫu:

> featureNames(ALL) [1:10]
[1] "1000_at" "1001_at" "1002_1_at" "1003_s_at" "1004_at" [6] "1006_at" "1006_at" "1007_s_at" "1008_f_at" "1009_at"

> sampleNanes (ALL) [1:5]
[1] 01005 01010" "03002" "04006" "04007" "

Mã này hiển thị tên của 10 gen đầu tiên và tên của 5 mẫu đầu tiên. Như đã đề cập trước đó, chúng tôi sẽ tập trung phân tích dữ liệu này vào các trường hợp ALL tế bào B và đặc biệt là các mẫu có một tập hợp con các đột biến, đây sẽ là lớp mục tiêu của chúng tôi. Mã bên dưới lấy tập hợp con dữ liệu mà chúng tôi sẽ sử dụng:

> tgt.cases <- which (ALLSBT %in% levels (ALL$BT) [1:5] &
+
ALL mol.bio XinX levels (ALLŝmol.bio) [1:4])
> ALLb <- ALL[,tgt.cases]
> ALLb
ExpressionSet (storageMode: lockedEnvironment) assayData: 12625 features, 94 samples
element names: exprs
protocolData: none
phenoData
sampleNanes: 01005 01010. LAL5 (94 total)
varLabels: cod diagnosis... date last seen (21 total)
varMetadata: labelDescription
featureData: none
experimentData: use 'experimentData(object)' pubMedIds: 14684422 16243790
Annotation: hgu95av2

 Câu lệnh đầu tiên lấy tập hợp các trường hợp mà chúng ta sẽ xem xét. Đây là các mẫu có giá trị cụ thể của biến BT và mol. bio. Kiểm tra các lệnh gọi đến hàm table() mà chúng ta đã trình bày trước đó để xem chúng ta đang chọn những lệnh nào. Sau đó, chúng ta chia nhỏ đối tượng ALL ban đầu để lấy 94 mẫu sẽ đưa vào nghiên cứu của chúng ta. Tập hợp các mẫu này chỉ chứa một số giá trị của biến BT và mol.bio. Trong bối cảnh này, chúng ta nên cập nhật các mức có sẵn của hai yếu tố 
này trên đối tượng ALLb mới của chúng ta:

> ALLbSBT <- factor (ALLbSBT)
> ALLb mol.bio <- factor (ALLbSmol.bio)

Đối tượng ALLb sẽ là tập dữ liệu mà chúng ta sẽ sử dụng trong suốt chương này. Cuối cùng, có thể lưu đối tượng này vào một tệp cục bộ trên máy tính của bạn, để bạn không cần phải lặp lại các bước xử lý trước này trong trường hợp bạn muốn bắt đầu phân tích từ đầu:

> save (ALLb, file = "myALL. Rdata")

7.2.1 Khám phá Bộ dữ liệu
Hàm exprs() cho phép chúng ta truy cập vào ma trận mức độ biểu hiện gen:

>es <- exprs (ALLb)
> din(es)
[1] 12625

 Ma trận tập dữ liệu của chúng tôi có 12.625 hàng (gen/đặc điểm) và 94 cột (mẫu/trường hợp).
 Về mặt chiều, thách thức chính của bài toán này là thực tế là có quá nhiều biến (12.625) cho số lượng trường hợp khả dụng (94). Với các chiều này, hầu hết các kỹ thuật mô hình hóa sẽ khó có thể thu được bất kỳ kết quả có ý nghĩa nào. Trong bối cảnh này, một trong những mục tiêu đầu tiên của chúng tôi là giảm số lượng biến, tức là loại bỏ một số gen khỏi phân tích của chúng tôi. Để hỗ trợ nhiệm vụ này, chúng tôi bắt đầu bằng cách khám phá dữ liệu mức độ biểu hiện.
 Hướng dẫn sau đây cho chúng tôi biết rằng hầu hết các giá trị biểu hiện nằm trong khoảng từ 4 đến 7:

 > summary(as.vector(es))
Min. 1st Qu. Median  Mean 3rd Qu. Max.
1.985 4.122  5.469  5.624 6.829 14.040

Có thể có được cái nhìn tổng quan tốt hơn về sự phân bố các mức biểu hiện bằng đồ họa. Chúng ta sẽ sử dụng một hàm từ gói genefilter (Gentleman và cộng sự, 2010). Gói này phải được cài đặt trước khi sử dụng. Xin lưu ý rằng đây là một gói Bioconductor và các gói này không được cài đặt từ kho lưu trữ R chuẩn. Cách dễ nhất để cài đặt một gói Bioconductor là thông qua tập lệnh do dự án này cung cấp cho hiệu ứng này:

> source("http://bioconductor.org/biocLite.R")
> biocLite("genefilter")
Hướng dẫn đầu tiên tải tập lệnh và sau đó chúng ta sử dụng nó để tải xuống và cài đặt gói. Bây giờ chúng ta có thể tiến hành hiển thị đồ họa được đề cập ở trên về phân phối các mức biểu thức, có kết quả được hiển thị 
trong Hình 7.1.

> library(genefilter)
> library(ggplot2)
> exprva <- data.frame(exprVal-as.vector(es))
> ds <- data.frame(Stat=c("1stQ","Median", "3rdQ", "Shorth"),
Value-c(quantile (exprVe$exprVal,
proba=c(0.25, 0.5, 0.75)),
shorth (exprVs$exprVal)),
Color=c("red", "green", "red", "yellow"))
ggplot(exprVs, aes(x=exprVal)) + geon_histogram (fill="lightgrey") + geom_vline(data-ds, aes(xintercept-Value, color-Color)) + geom_text(data=ds, aes(x-Value-0.2,y=0,label-Stat, colour-Color), angle=90,hjust="left") +
xlab("Expression Levels") guides (colour="none", fill="none")

Chúng tôi bắt đầu bằng cách lấy một khung dữ liệu chứa một vài số liệu thống kê mà chúng tôi sẽ thêm vào biểu đồ tần suất của các mức biểu hiện. Cụ thể là tứ phân vị thứ nhất và thứ ba, trung vị và shorth. Số liệu thống kê cuối cùng này là một ước tính mạnh mẽ về tính trung tâm của một phân phối liên tục được triển khai bởi hàm shorth() của gói genefilter. 
Nó được tính là giá trị trung bình của các giá trị trong một khoảng trung tâm chứa 50% các quan sát (tức là phạm vi liên tứ phân vị). Chúng tôi sử dụng geom_histogram() để lấy biểu đồ tần suất của các mức biểu hiện và sau đó sử dụng geom_vline() và geom_text() để thêm các đường thẳng đứng và nhãn văn bản cho từng số liệu thống kê. Như chúng ta có thể quan sát từ hình, 
các mức biểu hiện gen được đóng gói hợp lý xung quanh các số liệu thống kê tính trung tâm, với một vài giá trị lớn. Các phân phối của các mức biểu hiện gen của các mẫu có đột biến cụ thể có khác nhau không?
Sự phân bố mức độ biểu hiện gen của các mẫu có đột biến cụ thể có khác nhau không? Mã sau đây trả lời câu hỏi này:

# Không thể gắn hình ảnh vào file.

HÌNH 7.1: Sự phân bố mức độ biểu hiện gen.

> sapply(levels (ALLb mol.bio),
function(x) sunnary (as.vector(es[, which (ALLbŝnol.bio == x)))))

            ALL1/AF4  BCR/ABL  E2A/PBX1  NEG
Min.         2.266     2.195    2.268   1.985     
1st Qu.      4.141     4.124    4.152   4.111
Median       5.454     5468     5.497   5.470
Mean         5.621     5.627    5.630   5.622
3rd Qu.      6.805     6.833    6.819   6.832 
Max.         14.030    14.040   13.810  13.950

Như chúng ta thấy, mọi thứ khá giống nhau trên các tập hợp con mẫu này và hơn nữa, chúng tương tự như sự phân bố toàn cầu của các mức biểu hiện. Như một bài tập, bạn có thể thử tạo một biểu đồ hiển thị một số biểu đồ tương tự như biểu đồ được hiển thị trong Hình 7.1, một biểu đồ cho mỗi đột biến, bằng cách sử dụng các mặt ggplot.

7.3 Lựa chọn gen (Đặc điểm)
 Lựa chọn đặc điểm là một nhiệm vụ quan trọng trong nhiều vấn đề khai thác dữ liệu. Vấn đề chung là lựa chọn tập hợp con các đặc điểm (biến) của một vấn đề có liên quan hơn đến việc phân tích dữ liệu mà chúng ta dự định thực hiện. Điều này có thể được coi là một ví dụ của vấn đề tổng quát hơn về việc quyết định trọng số (tầm quan trọng) của các đặc điểm tronggiai đoạn mô hình hóa. Nhìn chung, có hai loại phương pháp tiếp cận để lựa chọn tính năng: (1) bộ lọc và (2) trình bao bọc. 
Như đã đề cập trong Phần 3.3.4.2 (trang 82), phương pháp trước sử dụng các thuộc tính thống kê của các tính năng để chọn tập cuối cùng, trong khi phương pháp sau bao gồm các công cụ khai thác dữ liệu trong quá trình lựa chọn. Các phương pháp tiếp cận bộ lọc được thực hiện trong một bước duy nhất, trong khi trình bao bọc thường liên quan đến quy trình tìm kiếm trong đó chúng ta lặp đi lặp lại tìm kiếm tập các tính năng phù hợp hơn với các công cụ khai thác dữ liệu mà chúng ta đang áp dụng. 
Trình bao bọc tính năng có chi phí rõ ràng về mặt tài nguyên tính toán. Chúng liên quan đến việc chạy toàn bộ chu trình lọc + mô hình + đánh giá nhiều lần cho đến khi đáp ứng được một số tiêu chí hội tụ. Điều này có nghĩa là đối với các vấn đề khai thác dữ liệu rất lớn, chúng có thể không phù hợp nếu thời gian là yếu tố quan trọng. Tuy nhiên, chúng sẽ tìm ra giải pháp về mặt lý thuyết phù hợp hơn với các công cụ mô hình hóa được sử dụng. Các chiến lược chúng tôi sử dụng và mô tả trong phần này có thể được coi là các phương pháp tiếp cận bộ lọc.
7.3.1 Bộ lọc đơn giản dựa trên các thuộc tính phân phối
Các phương pháp lọc gen đầu tiên mà chúng tôi mô tả dựa trên thông tin liên quan đến sự phân phối của các mức biểu hiện. Loại dữ liệu thực nghiệm này thường bao gồm một số gen không được biểu hiện hoặc có sự thay đổi rất nhỏ. Thuộc tính sau có nghĩa là những gen này khó có thể được sử dụng để phân biệt giữa các mẫu. Hơn nữa, loại microarray này thường có một số đầu dò kiểm soát có thể được loại bỏ an toàn khỏi phân tích của chúng tôi. Trong trường hợp nghiên cứu này, sử dụng microarray Affymetrix U95Av2, các đầu dò này có tên bắt đầu bằng các chữ cái "AFFX". 
Trong phân tích của chúng tôi, chúng tôi sẽ cần dữ liệu chú thích của bộ Affymetrix này nên chúng tôi cần gói hgu95av2.db (Carlson, 2016) từ dự án Bioconductor, có thể được cài đặt như sau:

> source("https://bioconductor.org/bioclite.R") 
> biocLite("hgu95av2.db")

Chúng ta có thể có được ý tưởng chung về sự phân bố mức độ biểu hiện của từng gen trên tất cả các cá thể với biểu đồ sau. Chúng ta sẽ sử dụng trung vị và khoảng tứ phân vị (IQR) làm đại diện cho các phân bố này. Mã sau đây thu được các điểm số này cho từng gen và vẽ các giá trị kết quả của chúng trên biểu đồ được hiển thị trong Hình 7.2:

> rowIQRS <- function(en)
+
rowQ (en, ceiling (0.75*ncol (em))) - rouQ (en, floor (0.25*ncol (en)))
> library(ggplot2)
> dg <- data.frame(rowMed-rowMedians (es), rowIQR-rowIQRs(es))
> ggplot(dg,aes(x=rowMed, y=rowIQR)) + geon_point() +
+
xlab("Median expression level") + ylab ("IQR expression level") + ggtitle("Main Characteristics of Genes Expression Levels")

Hàm rouMedians () từ gói Biobase lấy một vectơ của các trung vị trên mỗi hàng của một ma trận. Đây là một triển khai hiệu quả của nhiệm vụ này. Một giải pháp thay thế kém hiệu quả hơn là sử dụng hàm apply(). Hàm rouQ() là một triển khai hiệu quả khác do gói này cung cấp với mục tiêu là lấy các phân vị của một phân phối từ các hàng của một ma trận. Đối số thứ hai của hàm này là một số nguyên nằm trong khoảng từ 1 (sẽ cho chúng ta giá trị nhỏ nhất) đến số cột của ma trận (sẽ cho kết quả là giá trị lớn nhất). 
Trong trường hợp này, chúng ta đang sử dụng hàm này để lấy IQR bằng cách trừ tứ phân vị thứ 3 khỏi tứ phân vị thứ 1. Các số liệu thống kê này tương ứng với 75% và 25% dữ liệu. Chúng ta đã sử dụng các hàm floor() và ceiling() để lấy thứ tự tương ứng trong số các giá trị của mỗi hàng. Cả hai hàm đều lấy số nguyên

Phân loại mẫu Microarray
Đặc điểm chính của mức độ biểu hiện gen
Mức độ biểu hiện trung bình
# Không thể xuất hình ảnh lên file
HÌNH 7.2: Trung vị và IQR của mức độ biểu hiện gen.

Một phần của số dấu phẩy động, mặc dù có các thủ tục làm tròn khác nhau. Hãy thử nghiệm cả hai để thấy sự khác biệt. Sử dụng hàm row00), chủng tôi đã tạo hảm rowlQRs() để lấy IOR của mỗi hàng.
Hình 7.2 cung cấp thông tin thú vị. Cụ thể, chúng ta có thể quan sát thấy rằng một tỷ lệ lớn các gen có độ biến thiên rất thấp (IQR gần 0). Như đã đề cập ở trên, nếu một gen có độ biến thiên rất thấp trên tất cả các mẫu, thì có thể kết luận một cách khá an toàn rằng nó sẽ không hữu ích trong việc phân biệt giữa các loại đột biến khác nhau của ALL tế bào B. Điều này có nghĩa là chúng ta có thể loại bỏ an toàn các gen này khỏi nhiệm vụ phân loại của mình.
Chủng ta nên lưu ý rằng có một cảnh bảo về lý luận này. Trên thực tế, chúng ta đang xem xét các gen riêng lẻ. Điều này có nghĩa là có một số rủi ro rằng một số gen có độ biến thiên thấp này, khi kết hợp với các gen khác, thực sự có thể hữu ích cho nhiệm vụ phân loại. Tuy nhiên, phương pháp tiếp cận từng gen mà chúng ta sẽ áp dụng là phương pháp phổ biến nhất cho những vấn đề này vì việc khám phá các tương tác giữa các gen với các tập dữ liệu có chiều hưởng này không hề dễ dàng. 
Tuy nhiên, có những phương pháp cố gắng ước tính tầm quan trọng của các tính năng, có tính đến sự phụ thuộc của chúng. Đó là trường hợp của phương pháp RELIEF (Kira và Rendel, 1992; Kononenko và cộng sự, 1997) mà bạn có thể tìm thấy một triển khai trong gói CORElearn (Robnik-Sikonja và Savicky, 2015). Thông tin thêm về gói này và các gói khác được đưa ra trong Phần 3.3.4.2 (trang 82).
Chúng ta sẽ sử dụng ngưỡng houristic dựa trên giá trị của IOR để loại bỏ một số gen có độ biến thiên rất thấp. Cụ thể, chúng ta sẽ loại bỏ bất kỳ gen nào có độ biến thiên nhỏ hơn 15 IQR toàn cục.
Hàm nsFilter() từ gói genefilter có thể được sử dụng cho loại lọc này:

> library(genefilter)
> resFilter <- naFilter (ALLB,
> resFilter
Seset
var.func=IQR,
var.cutoff-IQR(as.vector(es))/5,
feature.exclude=""AFFX") "
ExpressionSet (storageMode: lockedEnvironment)
assayData: 3943 features, 94 samples
element names: exprs
protocolData: none
phenoData
sampleNanes: 01005 01010... LAL5 (94 total) varLabels: cod diagnosis... mol.bio (22 total) varMetadata: labelDescription
featureData: none
experimentData: use 'experimentData(object)' pubMedIds: 14684422 16243790
Annotation: hgu95av2
$filter.log
$filter.log$numDupsRemoved
[1] 2858
$filter.log3nunLowVar
[1] 4654
$filter.log nunRemoved. ENTREZID
[1] 1151
$filter.log$feature.exclude
[1] 19

Như bạn thấy, chúng ta chỉ còn lại 3.943 gen từ 12.625 gen ban đầu. Đây là một sự giảm đáng kể. Tuy nhiên, chúng ta vẫn còn rất xa một tập dữ liệu "có thể quản lý được" bởi hầu hết các mô hình phân loại, vì chúng ta chỉ có 94 quan sát.
Kết quả của hàm nsFilter() là một danh sách có một số thành phần. Trong số này, chúng ta có một số chứa thông tin về các gen đã loại bỏ và cũng có thành phần eset với đối tượng lớp ExpressionSet "đã lọc". Chúng ta có thể cập nhật các đối tượng ALLb và es của mình bằng đối tượng đã lọc:

> ALLb <- resFilterŝeset
> es <- exprs (ALLb)
> din(es)
[1] 3943 

7.3.2 Bộ lọc ANOVA
Nếu một gen có sự phân bố các giá trị biểu hiện giống nhau trên tất cả các giá trị có thể có của biến mục tiêu, thì sẽ không hữu ích lắm khi phân biệt giữa các giá trị này. Cách tiếp cận tiếp theo của chúng tôi dựa trên ý tưởng này. Chúng tôi sẽ so sánh mức biểu hiện trung bình của các gen trên các tập hợp con của các mẫu thuộc về một đột biến ALL tế bào B nhất định, tức là giá trị trung bình có điều kiện trên các giá trị biến mục tiêu. 
Các gen mà chúng tôi có độ tin cậy thống kê cao về việc có cùng mức biểu hiện trung bình trên các nhóm mẫu thuộc về mỗi đột biến sẽ bị loại khỏi phân tích tiếp theo. So sánh các giá trị trung bình trên nhiều hơn hai nhóm có thể được thực hiện bằng cách sử dụng kiểm định thống kê ANOVA. Trong nghiên cứu trường hợp của chúng tôi, chúng tôi có bốn nhóm trường hợp, một nhóm cho mỗi đột biến gen của ALL tế bào B mà chúng tôi đang xem xét. 
Việc lọc các gen dựa trên kiểm định này khá dễ dàng trong R, nhờ vào các tiện ích do gói genefilter cung cấp. Chúng tôi có thể thực hiện loại lọc này như sau:

> 1<- Anova (ALLbŝmol.bio, p = 0.01) >ff <- filterfun(f)
> selGenes <- genefilter (exprs (ALLb), ff)
> sum(selGenes)
[1] 746

Hàm Anova() tạo ra một hàm mới để thực hiện lọc ANOVA. Nó yêu cầu một yếu tố xác định các nhóm con của tập dữ liệu của chúng ta và một mức ý nghĩa thống kê. Hàm kết quả được lưu trữ trong biến 1. Hàm filterfun() hoạt động theo cách tương tự. Nó tạo ra một hàm lọc có thể được áp dụng cho ma trận biểu thức. Ứng dụng này được thực hiện với hàm genefilter() tạo ra một vectơ có số phần tử bằng số gen trong ma trận biểu thức đã cho. 
Vectơ chứa các giá trị logic. Các gen được coi là hữu ích theo phép thử thống kê ANOVA có giá trị TRUE. Như bạn có thể thấy, chỉ có 746. Cuối cùng, chúng ta có thể sử dụng vectơ này để lọc đối tượng ExpressionSet của mình. Tiếp theo, chúng ta cập nhật các cấu trúc dữ liệu của mình để chỉ bao gồm các gen đã chọn này:

> ALLb <- ALLb [selGenes, ]
> ALLb
ExpressionSet (storageMode: lockedEnvironment)
assayData: 746 features, 94 samples
element names: expra
protocolData: none
phenoData
sampleNanes: 01005 01010... LAL5 (94 total) varLabels: cod diagnosis... mol.bio (22 total) varMetadata: labelDescription
featureData: none
experimentData: use 'experimentData(object)'
pubMedIda: 14684422 16243790
Annotation: hgu95av2
>es <- exprs (ALLb)
> din(es)
[1] 746 

Hình 7.3 cho thấy giá trị trung bình và IQR của các gen được chọn bằng phép thử ANOVA.
Hình được thu được như sau:

Mức biểu hiện IQR
Mức biểu hiện trung bình
# Không thể xuất hình ảnh lên file
HÌNH 7.3: Trung bình và IQR của bộ gen cuối cùng.

> dg <- data.frame(rowMed-rowMedians (es), rowIQR=rowIQRs(es))
> ggplot(dg, aes(x-rowMed, y=rowIQR)) + geon_point() +
+
+
xlab ("Median expression level") + ylab ("IQR expression level") + ggtitle("Distribution Properties of the Selected Genes")
Sự thay đổi về IQR và trung vị mà chúng ta có thể quan sát thấy trong Hình 7.3 cung cấp bằng chứng cho thấy các gen được biểu hiện ở các thang giá trị khác nhau. Một số kỹ thuật mô hình hóa chịu ảnh hưởng của các vấn đề trong đó mỗi trường hợp được mô tả bằng một tập hợp các biến sử dụng các thang khác nhau. 
Cụ thể, bất kỳ phương pháp nào dựa vào khoảng cách giữa các quan sát sẽ gặp phải loại vấn đề này vì các hàm khoảng cách thường tổng hợp các khác biệt giữa các giá trị biến. Trong bối cảnh này, các biến có giá trị trung bình cao hơn sẽ có ảnh hưởng lớn hơn đến khoảng cách giữa các quan sát. Để tránh hiệu ứng này, người ta thường chuẩn hóa dữ liệu. 
Phép biến đổi này bao gồm trừ đi giá trị điển hình của các biến và chia kết quả cho một phép đo độ phân tán. Vì không phải tất cả các kỹ thuật mô hình hóa đều bị ảnh hưởng bởi đặc điểm dữ liệu này nên chúng ta sẽ để phép biến đổi này cho các giai đoạn mô hình hóa, khiến nó phụ thuộc vào công cụ được sử dụng.

7.3.3 Lọc bằng Rừng ngẫu nhiên
Ma trận mức biểu thức thu được từ bộ lọc ANOVA đã có kích thước có thể quản lý được, mặc dù chúng ta vẫn có nhiều tính năng hơn so với các quan sát. Trên thực tế, trong các nỗ lực mô hình hóa của chúng tôi được mô tả trong Phần 7.4, chúng tôi sẽ áp dụng các mô hình đã chọn vào ma trận này. Tuy nhiên, người ta có thể đặt câu hỏi liệu có thể thu được kết quả tốt hơn với một tập dữ liệu có một chiều "chuẩn" hơn. 
Trong bối cảnh này, chúng ta có thể thử giảm thêm số lượng các tính năng và sau đó so sánh các kết quả thu được với các tập dữ liệu khác nhau.
Rừng ngẫu nhiên có thể được sử dụng để có được thứ hạng của các tính năng theo mức độ hữu ích của chúng đối với một nhiệm vụ phân loại. Trong Phần 5.3.2 (trang 112), chúng ta đã thấy một ví dụ về việc sử dụng rừng ngẫu nhiên để có được thứ hạng về tầm quan trọng của các biến trong bối cảnh của một vấn đề dự đoán.
Rừng ngẫu nhiên có thể được sử dụng để có được thứ hạng của các gen như sau,

> library(randonForest)
> dt <- data.frame(t(es), Mut = ALLbŝnol.bio)
> dt Mut<- droplevels (dtsMut)
> set.seed(1234)
> rf <- randomForest (Mut - dt, importance = TRUE)
> imp <- importance(rf)
> rf.genes <- rownanes (imp) [order(imp[, "MeanDecreaseAccuracy"],
decreasing= TRUE) [1:30]]

Chúng tôi xây dựng một tập huấn luyện bằng cách thêm thông tin đột biến vào phép chuyển vị của ma trận biểu thức. Sau đó, chúng tôi thu được một khu rừng ngẫu nhiên với tham số importance được đặt thành TRUE để thu được ước tính về tầm quan trọng của các biến. Hàm importance() được sử dụng để thu được mức độ liên quan của từng biến.
Hàm này thực sự trả về một số điểm trên các cột khác nhau, theo các tiêu chí khác nhau và cho từng giá trị lớp. Chúng tôi chọn cột có điểm biến được đo là mức giảm trung bình ước tính về độ chính xác phân loại khi từng biến bị loại bỏ lần lượt. Chúng tôi sắp xếp các giá trị của điểm này theo thứ tự giảm dần và chọn 30 điểm cao nhất trong số các điểm này, thu được tên của các gen tương ứng.
Chúng tôi có thể tò mò về sự phân bố mức độ biểu hiện của 30 gen này trên các đột biến khác nhau. Chúng tôi có thể thu được mức độ trung bình cho 30 gen hàng đầu này như sau:

>sapply(rf.genes, function(g) tapply (dt [, g), dt Mut, median))

              X1635 at  X40504_at  X1467_at  X37015_at  X1674_at  X34699_at
ALL1/AF4      7.302814  3.218079   3.708985  3.752649   3.745752  4.253504
BCR/ABL       8.693082  4.924310   4.239306  4.857105   5.833510  6.315966
E2A/PBX1      7.562676  3.455316   3.411696  6.579530   3.808258  6.102031
NEG           7.324691  3.541651   3.515020  3.765741   4.244791  6.092511

              X39837_s_at  X37027_at  X37225_at  X40202_at  X40480_s_at  X34850_at
ALL1/AF4      6.633188     9.118515   5.220668   8.550639   6.414368     5.426653      
BCR/ABL       7.374046     9.421987   3.460902   9.767293   8.208263     6.898979
E2A/PBX1      6.708400     6.688977   7.445655   7.414635   6.722296     5.928574     
NEG           6.878846     7.408175   3.387552   7.655605   7.362318     6.327281 

              X34210_at  X1307_at  X36873_at  X41470_at  X40454_at  X41237_at 
ALL1/AF4      5.641130   3.368915  7.040593   9.616743   4.007171   10.94079
BCR/ABL       9.204237   4.945270  3.490262   5.205797   3.910912   12.11895
E2A/PBX1      8.198781   4.678577  3.634471   3.931191   7.390283   11.35610
NEG           8.791774   4.863930  3.824670   4.157748   3.807652   11.93624

              X40795_at  X32378_at  X1914_at  X37951_at  X37981_at  X37579_at 
ALL1/AF4      3.867134   8.703860   7.066848  3.418433   6.170311   7.614200
BCR/ABL       4.544239   9.694933   3.935540  3.881780   6.882755   8.231081
E2A/PBX1      4.151637   10.066073  3.761856  3.461861   8.080002   9.494368
NEG           3.909532   9.743168   4.032755  3.419113   7.423079   8.455750
              X36617_at  X32434_at  X41191_at X36275_at  X36638_at  X37105_at
   
Khai thác dữ liệu bằng R: Học với các nghiên cứu tình huống
# Không thể xuất hình ảnh lên file
HÌNH 7.4: Trung vị và IQR của mức độ biểu hiện gen trên các đột biến.

ALL1/AF4   6.438007   3.317480   6.314058   3.618819   9.811828   6.845719 
BCR/ABL    7.480436   5.339625   4.459709   6.259073   8.486446   6.493001 
E2A/PBX1   6.627934   3.668714   4.325834   3.635956   6.259730   6.740213 
NEG        6.561701   3.226766   4.369366   3.749953   5.856580   6.298859

Chúng ta có thể quan sát một số khác biệt thú vị giữa mức biểu hiện trung bình trên các loại đột biến, điều này cung cấp một chỉ báo tốt về sức mạnh phân biệt của các gen này. Chúng ta có thể thu được nhiều chi tiết hơn nữa bằng cách kiểm tra đồ họa các phạm vi trung bình và liên tứ phân vị của mức biểu hiện của các gen này đối với 94 mẫu:

> library(tidyr)
> library(dplyr)
> d <- gather (dt [,c(rf. genes, "Mut")], Gene, ExprValue, 1:length(rf.genes))
> dat <- group_by(d, Mut, Gene) %>%
+ summarise (med-median (ExprValue), iqr-IQR(ExprValue))
> ggplot(dat, aes(x-ned, y=iqr,color=Mut)) +
+
geon point(size-6) facet_wrap(~ Gene) +
labs(x="MEDIAN expression level",y="IQR expression level",color="Mutation")

Biểu đồ thu được với mã này được hiển thị trong Hình 7.4. Chúng tôi quan sát thấy có một số gen có sự khác biệt rõ rệt về mức độ biểu hiện giữa các đột biến khác nhau. Ví dụ, có sự khác biệt rõ ràng về mức độ biểu hiện tại gen X41470_at (bảng dưới cùng bên phải) giữa ALL1/AF4 và các đột biến khác. Điều tương tự cũng xảy ra với gen X4045_at đối với đột biến E2A/PBX1, 
trong số những sự khác biệt ít rõ rệt khác. Để có được biểu đồ này, chúng tôi đã sử dụng hàm gather() của gói tidyr. Hàm này đưa dữ liệu biểu thức gốc vào định dạng dễ tóm tắt hơn khi sử dụng gói dplyr.

7.3.4 Lọc bằng cách sử dụng cụm tính năng tập hợp
Phương pháp được mô tả trong phần này sử dụng thuật toán cụm để thu được 30 nhóm biến được cho là tương tự nhau. Sau đó, 30 cụm biến này sẽ được sử dụng để thu được mô hình phân loại tập hợp, trong đó m mô hình sẽ được thu được với 30 biến, mỗi biến được chọn ngẫu nhiên từ một trong 30 cụm.
Tập hợp là phương pháp học xây dựng một tập hợp các mô hình dự đoán và sau đó phân loại các quan sát mới bằng một số hình thức tính trung bình các dự đoán của các mô hình này. Chúng được biết đến là thường vượt trội hơn các mô hình riêng lẻ tạo nên tập hợp. Tập hợp dựa trên một số hình thức đa dạng giữa các mô hình riêng lẻ. Có nhiều hình thức tạo ra sự đa dạng này.
 Ví dụ, có thể thông qua các thiết lập tham số mô hình khác nhau hoặc bằng các mẫu quan sát khác nhau được sử dụng để thu được từng mô hình. Một giải pháp thay thế khác là sử dụng các bộ dự đoán khác nhau cho từng mô hình trong tập hợp. Các tập hợp chúng ta sử dụng trong phần này tuân theo chiến lược sau này. 
Cách tiếp cận này hiệu quả hơn nếu nhóm các biến dự đoán mà chúng ta thu được các tập hợp khác nhau có tính dự phòng cao. Chúng ta sẽ giả định rằng có một số mức độ dự phòng trên tập hợp các tính năng do bộ lọc ANOVA tạo ra. Chúng ta sẽ cố gắng mô hình hóa tính dự phòng này bằng cách nhóm các biến. Các phương pháp nhóm dựa trên khoảng cách, 
trong trường hợp này là khoảng cách giữa các biến. Hai biến gần (và do đó tương tự) với nhau nếu các giá trị biểu hiện của chúng trên 94 mẫu tương tự nhau. Bằng cách nhóm các biến, chúng ta mong đợi tìm thấy các nhóm gen tương tự nhau. Gói Hmisc chứa một hàm sử dụng thuật toán nhóm phân cấp để nhóm các biến của một tập dữ liệu. Tên của hàm này là varclus (). Chúng ta có thể sử dụng nó như sau: 
 
> library(Hnisc)
>
vc <- varclus(t(es))
> clus30 <- cutree (vchclust, 30)
> table(clus30)
clus30
1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 18 34 30 22 34 35 19 
16 40 52 19 22 17 24 30 26 20 17 18 21 43 30 32 14 23 26 27 28 29 30
28 18 17 11 16

Chúng tôi đã sử dụng hàm cutree() để có được một cụm được hình thành bởi 30 nhóm biến. Sau đó, chúng tôi kiểm tra xem có bao nhiêu biến (gen) thuộc về mỗi cụm. Dựa trên cụm này, chúng tôi có thể tạo ra các bộ dự báo bằng cách chọn ngẫu nhiên một biến từ mỗi cụm. Lý do là các thành viên của cùng một cụm sẽ giống nhau và do đó theo một cách nào đó là trùng lặp.
Hàm sau đây tạo điều kiện thuận lợi cho quá trình này bằng cách tạo ra một bộ biến thông qua việc lấy mẫu ngẫu nhiên từ số cụm đã chọn (mặc định là 30):

>getVarsSet <- function (cluster,nvars-30, seed-NULL, verb-FALSE) {
+    if (!is.null(seed)) set.seed(seed)
+    cls <- cutree (cluster,nvars)

+    vars <- c()
+    tots <- table(cls)
+    vars <- sapply(1:nvars, function(clID)
+    {

+      if (!length(tots [clID])) stop('Empty cluster! (',clID, ')') 
+      x <- sample(1: tota [clID],1)
+      names(cls [cls==clID]) [x]
+      }}
+    if (verb) structure (vars, clusMenb-cls, clusTota=tota)
+    else      vars
> getVarsSet (vchclust)


[1]  "X40127_at"  "X745_at"   "X35694_at"   "X187_at"   "X34877_at"
[6]  "X39929_at"  "X32156_at" "X39738_at"   "X32724_at" "X38980_at"
[11] "X38732_at"  "X33772_at" "X245_at"     "X33283_at" "X34362_at"
[16] "X1453_at"   "X34850_at" "X36412_s_at" "X38748_at" "X37213_at"
[21] "X36275_at"  "X36795_at" "X32824_at"   "X506_s_at" "X33999_f_at"
[26] "X40745_at"  "X38158_at" "X41559_at"   "X1616_at"  "X36550_at"          

>getVarsSet (vc$hclust)

[1] "X40505_at"    "X40409_at"  "X1635_at"     "X37981_at"   "X41498_at"
[6] "X39837_8_at"  "X40323_at"  "X39650_8_at"  "X40495_at"   "X32621_at" 
[11] "X39377_at"   "X34335_at"  "X36493_at"    "X32963_s_at" "X174_s_at" 
[16] "X39781_at"   "X539_at"    "X33325_at"    "X35670_at"   "X37304_at" 
[21] "X809_at"     "X40575_at"  "X34785_at"    "X38956_at"   "X41146_at" 
[26] "X40425_at"   "X33429_at"  "X33920_at"    "X33528_at"   "X39136_at"

Mỗi lần chúng ta gọi hàm này, chúng ta sẽ nhận được một tập hợp "mới" gồm 30 biến. Sử dụng hàm này, bạn có thể dễ dàng tạo ra một tập hợp dữ liệu được hình thành bởi các yếu tố dự báo khác nhau, sau đó thu được một mô hình sử dụng từng tập hợp này. Trong Phần 7.4, chúng tôi trình bày một hàm thu được các tập hợp sử dụng chiến lược này. Đọc thêm về lựa chọn tính năng.
Lựa chọn tính năng là một chủ đề được nghiên cứu kỹ lưỡng trong nhiều lĩnh vực. Có thể tìm thấy các bản tổng quan và tài liệu tham khảo tốt về công trình trong lĩnh vực khai thác dữ liệu trong Liu và Motoda (1998), Chizi và Maimon (2005) và Wettschereck và cộng sự (1997). Có thể tìm thấy thêm thông tin và tài liệu tham khảo trong Phần 3.3.4.2 (trang 82).

7.4 Dự đoán các bất thường về di truyền tế bào
Phần này mô tả các nỗ lực lập mô hình của chúng tôi cho nhiệm vụ dự đoán loại bất thường về di truyền tế bào của các trường hợp ALL tế bào B.

7.4.1 Xác định nhiệm vụ dự đoán
Vấn đề khai thác dữ liệu mà chúng ta đang phải đối mặt là một nhiệm vụ dự đoán. Chính xác hơn, đây là một vấn đề phân loại. Phân loại dự đoán bao gồm việc thu thập các mô hình được thiết kế với mục tiêu dự báo giá trị của một biến mục tiêu danh nghĩa bằng cách sử dụng thông tin về một tập hợp các yếu tố dự đoán. 
Các mô hình được thu thập bằng cách sử dụng một tập hợp các quan sát được gắn nhãn của hiện tượng đang nghiên cứu, tức là các quan sát mà chúng ta biết cả giá trị của các yếu tố dự đoán và của biến mục tiêu. Trong trường hợp nghiên cứu này, biến mục tiêu của chúng ta là loại bất thường về tế bào học của tế bào B

Tất Cả mẫu. Trong tập dữ liệu đã chọn của chúng tôi, biến này sẽ có bốn giá trị có thể: ALL1IAFA, BCRIABL, E2A/PBX1 và NEG. Về các yếu tố dự báo, chúng sẽ bao gồm một tập hợp các gen đã chọn mà chúng tôi đã đo được giá trị biểu hiện. Trong các nỗ lực lập mô hình, chúng tôi sẽ thử nghiệm với các tập hợp gen đã chọn khác nhau, dựa trên nghiên cứu được mô tả trong Phần 7.3. 
Điều này có nghĩa là số lượng các yếu tố dự bảo (đặc điểm) sẽ thay đổi tùy thuộc vào các thử nghiệm này. Về số lượng quan sát, chúng sẽ bao gồm 94 trường hợp mắc bệnh ALL tế bào B.

7.4.2 Đo lường đánh giá
Nhiệm vụ dự đoán là một vấn đề phân loại đa lớp. Các mô hình phân loại dự đoán thường được 369 đánh giá bằng cách sử dụng tỷ lệ lỗi hoặc phần bù của nó, độ chính xác. Tuy nhiên, có một số phương an thay thế, chẳng hạn như diện tích dưới đường cong ROC, các cặp biện pháp (ví dụ: độ chính xác và độ thu hồi), và cũng có các biện pháp về độ chính xác của ước tính xác suất lớp (ví dụ: điểm Brier).
Gói ROCR cung cấp một mẫu tốt về các biện pháp này. Việc lựa chọn số liệu đánh giá cho một vấn đề nhất định thường phụ thuộc vào mục tiêu của người dùng. Đây là một quyết định khó khăn thường bị ảnh hưởng bởi thông tin không đầy đủ như thiếu thông tin về chi phi phân loại sai trường hợp loại i thành loại j (được gọi là chi phí phân loại sai).
Trong nghiên cứu trưởng hợp của chúng tôi, chúng tôi không có thông tin về chi phi phân loại sai, và do đó chúng tôi cho rằng việc phân loại sai, ví dụ, đột biến E2A/PBX1 thành NEG, cũng nghiêm trọng như việc phân loại sai ALL/AF4 thành BCRIABL. Hơn nữa, chúng tôi có nhiều hơn hai lớp và việc khái quát hóa phân tích RỌC đối với các vấn đề đa lớp chưa được thiết lập tốt, 
chưa kể đến những nhược điểm gần đây được phát hiện trong việc sử dụng diện tích dưới đường cong ROC (Hand, 2009). Trong bối cảnh này, chúng tôi sẽ sử dụng độ chính xác tiêu chuẩn được đo là:

# Công thức có những ký tự đặc biệt nên em không thể điền được (7.1) và (7.2)
N-1 đó N là kích thước của mẫu thử nghiệm và Lo/1() là hàm mất mát được định nghĩa là Lo/1(4,94)

7.4.3 Quy trình thực nghiệm

Số lượng quan sát của tập dữ liệu mà chúng ta sẽ sử dụng khá nhỏ: 94 trường hợp. Trong bối cảnh này, phương pháp thực nghiệm đầy đủ hơn để có được ước tính đảng tin cậy về tỷ lệ lỗi là bootstrap hoặc Leave-One-Out Cross-Validation (LOOCV). LOOCV là trường hợp đặc biệt của phương pháp thực nghiệm cross-validation k-fold mà chúng ta đã sử dụng trước đây, cụ thể là khi k bằng số lượng quan sát. 
Tóm lại, LOOCV bao gồm việc thu thập N mô hình, trong đó N là kích thước tập dữ liệu và mỗi mô hình được thu thập bằng cách sử dụng N-1 trường hợp và được thử nghiệm trên quan sát bị loại bỏ. Gói performanceEs-timation cũng bao gồm phương pháp này như một trong những phương pháp ước tính mà bạn có thể chỉ định trong định nghĩa của tác vụ ước tính.
Bootstrap là một phương pháp khác thường được sử dụng với các mẫu nhỏ như trường hợp của bài toán của chúng ta. Về cơ bản, nó bao gồm việc rút một mẫu ngẫu nhiên với sự thay thế cùng kích thước của tập dữ liệu gốc. Vì mẫu được rút ra với sự thay thế nên điều đó có nghĩa là một số trường hợp sẽ xuất hiện lặp lại trong khi những trường hợp khác sẽ không được rút ra. 
Những cái sau này sẽ tạo thành bộ kiểm tra, trong đó chúng ta sẽ áp dụng mô hình thu được với cái trước. Việc lấy mẫu ngẫu nhiên này thường được lặp lại nhiều lần (ví dụ: 100 hoặc 200). Ước tỉnh bootstrap được lấy bằng trung bình của các điểm thu được trong những lần lặp lại này. Gói hiệu suất ước tính cung cấp hai triển khai của phương pháp ước tính bootstrap: 60 và 632 bootstrap (chi tiết trên Mục 3.5.3, trang 179). 
Dưới đây là một minh họa nhỏ về bootstrap với tập dữ liệu Iris:

> library(performanceEstimation)
> library(DMuR2)
> data(iris)
> exp <- performance Estination(
+     PredTask(Species., iris),
+     Workflow (learner="rpartise", predictor.pars-list (type="class")),
+     EstimationTask(metrics="acc",method-Bootstrap (nReps=100)))

> summary(exp)


== Summary of a Bootstrap Performance Estimation Experiment ==

Task for estinating ace using
100 repetitions of e0 Bootstrap experiment
Run with seed 1234

* Predictive Tasks ::  iris.Species
• Workflows :: rpartXse
-> Task: iris. Species
  •Workflow: rpartXse
               acc
avg      0.94488494
std      0.02534310
med      0.94736842
iqr      0.03569024
min      0.87931034
пах      1.00000000
invalid  0.00000000

7.4.4 Các kỹ thuật lập mô hình

Như đã thảo luận trước đó, chúng tôi sẽ sử dụng ba tập dữ liệu khác nhau có các yếu tố dự báo khác nhau. Một tập sẽ chọn tất cả các gen bằng phép thử ANOVA, trong khi hai tập còn lại sẽ chọn 30 gen trong số này. Tất cả các tập dữ liệu sẽ chứa 94 trường hợp mắc ALL tế bào B. Ngoại trừ biến mục tiêu, tất cả thông tin đều là số.
Để giải quyết vấn đề này, chúng tôi đã chọn ba kỹ thuật lập mô hình khác nhau. Hai trong số chúng đã được sử dụng trước đó trong cuốn sách này. Chúng là rừng ngẫu nhiên và máy vectơ hỗ trợ (SVM). Chúng được công nhận là một số phương pháp dự đoán tốt nhất có sẵn. Thuật toán thứ ba mà chúng tôi sẽ thử cho vấn đề này là thuật toán mới. 
Đây là phương pháp dựa trên khoảng cách giữa các quan sát, được gọi là k-gần nhất. Việc sử dụng rừng ngẫu nhiên xuất phát từ thực tế là các mô hình này đặc biệt phù hợp để xử lý các vấn đề có số lượng lớn các tính năng. Thuộc tính này bắt nguồn từ thuật toán được các phương pháp này sử dụng để chọn ngẫu nhiên các tập hợp con của toàn bộ các tính năng của một vấn đề. 
Về việc sử dụng k-gần nhất, động lực nằm ở giả định rằng các mẫu có cùng đột biến phải có "chữ ký" gen tương tự, nghĩa là phải có các giá trị biểu hiện tương tự trên các gen mà chúng ta sử dụng để mô tả chúng. Tính hợp lệ của điều này giả định phụ thuộc mạnh vào các gen được chọn để mô tả các mẫu. 
Cụ thể là chúng phải có các đặc tính phân biệt tốt giữa các đột biến khác nhau. Như chúng ta sẽ thấy bên dưới, các phương pháp k-nearest neighbors hoạt động bằng cách đánh giá điểm tương đồng giữa các trường hợp và do đó chúng có vẻ phù hợp với giả định này. Cuối cùng, 
việc sử dụng SVM được biện minh với mục tiêu cố gắng khám phá các mối quan hệ phi tuyến tính có thể tồn tại giữa biểu hiện gen và các bất thường về tế bào học. Cả rừng ngẫu nhiên và máy vectơ hỗ trợ đều đã được mô tả trong các chương trước. Thông tin chi tiết về rừng ngẫu nhiên và các loại tập hợp khác đã được trình bày trong Phần 3.4.5.5 (trang 165).
Mặt khác, SVM đã được mô tả chi tiết trong Phần 3.4.5.3 (trang 151). Thuật toán k-nearest neighbors thuộc về lớp được gọi là người học lười biếng. Loại kỹ thuật này thực sự không lấy mô hình từ dữ liệu đào tạo. Chúng chỉ lưu trữ tập dữ liệu này. Công việc chính của chúng diễn ra tại thời điểm dự đoán. Với một trường hợp thử nghiệm mới, 
dự đoán của trường hợp đó được thực hiện bằng cách tìm kiếm các trường hợp tương tự trong dữ liệu đào tạo đã được lưu trữ. Các trường hợp đào tạo k tương tự nhất được sử dụng để có được dự đoán cho trường hợp thử nghiệm đã cho. Trong các vấn đề phân loại, dự đoán này thường thu được bằng cách bỏ phiếu và do đó, một số lẻ cho & là mong muốn. 
Tuy nhiên, các cơ chế bỏ phiếu phức tạp hơn có tính đến khoảng cách của trường hợp thử nghiệm đến mỗi k hàng xóm cũng khả thi. Đối với hồi quy, thay vì bỏ phiếu, chúng ta có giá trị trung bình của các giá trị biến mục tiêu của các hàng xóm &.
Kiểu mô hình này phụ thuộc mạnh vào khái niệm về sự tương đồng giữa các trường hợp. Khái niệm này thường được định nghĩa với sự trợ giúp của một phép đo trên không gian đầu vào được xác định bởi các biến dự đoán. Phép đo này là một hàm khoảng cách có thể tính toán một số biểu thị 
"sự khác biệt giữa bất kỳ hai quan sát nào. Có nhiều hàm khoảng cách, nhưng một lựa chọn khá phổ biến là hàm khoảng cách Euclid được định nghĩa là: "

# Công thức có những ký tự đặc biệt nên không để xuất lên  (trong đó p là số lượng yếu tố dự báo và x; và x; là hai quan sát).

Do đó, các phương pháp này rất nhạy cảm với cả số liệu đã chọn và cả sự hiện diện của các biến không liên quan có thể làm sai lệch khái niệm về tính tương đồng. Hơn nữa, quy mô của các biến phải đồng nhất; nếu không, chúng ta có thể đánh giá thấp một số khác biệt giữa các biến có giá trị trung bình thấp hơn.
Việc lựa chọn số lượng hàng xóm (k) cũng là một tham số quan trọng của các phương pháp này. Các giá trị thường xuyên bao gồm các số trong tập hợp (1,3,5,7, 11), nhưng rõ ràng đây chỉ là phương pháp tìm kiếm. Tuy nhiên, chúng ta có thể nói rằng nên tránh các giá trị k lớn hơn vì có nguy cơ sử dụng các trường hợp đã cách xa trường hợp thử nghiệm. 
Rõ ràng, điều này phụ thuộc vào mật độ của dữ liệu đào tạo. Các tập dữ liệu quá thưa thớt sẽ phải chịu nhiều rủi ro hơn. Như với bất kỳ mô hình học tập nào, các thiết lập tham số "lý tưởng" có thể được ước tính thông qua một số phương pháp thực nghiệm. Trong R, lớp gói (Venables và Ripley, 2002) bao gồm hàm knn() triển khai ý tưởng này. 
Dưới đây là một ví dụ minh họa về việc sử dụng nó trên tập dữ liệu Iris:

> library(class)
> data(iris)
> idx <- sample(1:nrow(iris), as. integer (0.7 nrow(iris)))
> tr <- iris[idx, ]
>ts <- iris[-idx, ]
> preds <- knn(tr[, -5], ts[, -5], tr[, 5], k = 3)
> table (preds, ta【, 5])

 Khai thác dữ liệu với R: Học tập với các nghiên cứu tình huống

 preds         setosa  versicolor  irginica
   setosa        13        0          0
   versicolor    0         9          0
   virginica     0         2          21

Như bạn thấy, hàm knn() sử dụng một giao diện không chuẩn. Đối số đầu tiên là tập huấn luyện ngoại trừ biến mục tiêu column. Đối số thứ hai là tập kiểm tra, một lần nữa không có mục tiêu. Đối số thứ ba bao gồm các giá trị mục tiêu của dữ liệu huấn luyện. Cuối cùng, có một số tham số khác kiểm soát phương pháp, trong đó tham số k xác định số lượng hàng xóm. 
Chúng ta có thể tạo một hàm nhỏ cho phép sử dụng phương pháp này trong một giao diện kiểu công thức chuẩn hơn:

> KNN <- function (form, train, test, stand TRUE, stand.stats- NULL, ...) {
+       require(class, quietly = TRUE)
+       tgtCol <- which(colnames(train) == as.character (form [[2]])) 
+       if (stand) {
+           if (is.null(stand.stats))
                tmp <- scale(train[, -tgtCol], center= TRUE, scale = TRUE) 
                else tmp <- scale(train[, -tgtCol], center stand.stats[[1]], 
                                  scale stand.stats[[2]])
+               train, tgtCol] <- tmp
+               ma <- attr(tmp, "scaled: center")
+               ss <- attr(tmp, "scaled: scale")
+               test, tgtCol] <- scale(test [, tgtCol], centerns, scale = ss)
        }
+       knn(train, tgtCol], test[, -tgtCol], train[, tgtCol], ...)
+ }

> preds.stand <- kNN (Species, tr, ts, k = 3)
> table (preds.stand, ts[, 5])

preds.stand   setosa   versicolor   virginica
setosa          13         0            0
versicolor      0          10           2
virginica       0          1            19

> preds.notStand <- KNN (Species - ..tr, ts, stand= FALSE, = 3) 
> table (preds.notStand, ts[, 5])


preds.notStand   setosa   versicolor   virginica
setosa             13         0            0
versicolor         0          9            0  
virginica          0          2            21

Hàm này cho phép người dùng chỉ ra liệu dữ liệu có nên được chuẩn hóa trước khi gọi hàm knn() hay không. Điều này được thực hiện thông qua tham số stand. Trong ví dụ trên, bạn thấy hai ví dụ về cách sử dụng của nó. Một giải pháp thay thế thứ ba là cung cấp số liệu thống kê về độ tập trung và độ lan tỏa dưới dạng danh sách với hai thành phần trong đối số stand. stats.
Nếu không thực hiện điều này, hàm sẽ sử dụng giá trị trung bình làm ước tính độ tập trung và độ lệch chuẩn làm số liệu thống kê về độ lan tỏa. Trong các thí nghiệm của mình, chúng ta sẽ sử dụng tiện ích này để gọi hàm với trung vị và IQR.  Hàm KNN() thực sự được bao gồm trong gói sách của chúng tôi nên bạn không cần phải nhập mã của nó.

Tài liệu tham khảo chuẩn về loại phương pháp này là công trình của Cover và Hart (1967). Có thể tìm thấy tổng quan tốt trong các công trình của Aha và cộng sự (1991) và Aha (1997). Có thể tìm thấy phân tích sâu hơn trong luận án tiến sĩ của Aha (1990) và Wettschereck (1994). Một góc nhìn khác nhưng có liên quan về học lười biếng là sử dụng cái gọi là mô hình cục bộ (Nadaraya, 1964; Watson, 1964). 
Tài liệu tham khảo tốt về lĩnh vực rộng lớn này là Atkeson và cộng sự (1997) và Cleveland và Loader (1995).

7.4.5 So sánh các mô hình

Phần này mô tả quy trình chúng tôi đã sử dụng để so sánh các mô hình đã chọn bằng quy trình ước tính bootstrap. Trong Phần 7.3, chúng tôi đã thấy các ví dụ về một số phương pháp chọn tính năng. Chúng tôi đã sử dụng một số bộ lọc cơ bản để loại bỏ các gen có phương sai thấp và cũng kiểm soát các đầu dò. Tiếp theo, 
chúng tôi áp dụng một phương pháp dựa trên phân phối có điều kiện của các mức biểu hiện liên quan đến biến mục tiêu. Phương pháp này dựa trên kiểm định thống kê ANOVA. Cuối cùng, từ kết quả của kiểm định này, chúng tôi đã cố gắng giảm thêm số lượng gen bằng cách sử dụng rừng ngẫu nhiên và phân cụm các biến. Ngoại trừ các bộ lọc đơn giản đầu tiên, tất cả các phương pháp khác đều phụ thuộc vào giá trị biến mục tiêu. 
Chúng tôi có thể đặt câu hỏi liệu các giai đoạn lọc này có nên được thực hiện trước khi so sánh thử nghiệm hay không hoặc liệu chúng tôi có nên tích hợp các bước này vào các quy trình đang được so sánh hay không. Nếu mục tiêu của chúng tôi là có được ước tính không thiên vị về độ chính xác phân loại của phương pháp luận của chúng tôi trên các mẫu mới, thì chúng tôi nên đưa các giai đoạn lọc này vào như một phần của quy trình 
công việc đang được đánh giá và so sánh. Nếu không làm như vậy, có nghĩa là các ước tính chúng tôi thu được sẽ bị thiên vị do thực tế là các gen được sử dụng để có được các mô hình đã được chọn bằng thông tin của bộ kiểm tra. Trên thực tế, nếu chúng tôi sử dụng tất cả các tập dữ liệu để quyết định sử dụng gen nào, thì chúng tôi đang sử dụng thông tin về quy trình lựa chọn này mà thông tin này không được biết vì nó là một phần của dữ liệu kiểm tra. 
Trong bối cảnh này, chúng tôi sẽ đưa một phần các giai đoạn lọc vào trong các hàm quy trình làm việc do người dùng xác định để triển khai các mô hình mà chúng tôi sẽ so sánh. Các phương pháp tiếp cận mà chúng tôi sẽ so sánh bao gồm các quy trình lựa chọn tính năng thay thế khác nhau và cũng như các công cụ phân loại khác nhau để áp dụng cho các tập dữ liệu đã lọc kết quả. Cụ thể hơn, chúng tôi sẽ xem xét về mặt lựa chọn tính năng: 
(i) sử dụng các gen thu được từ quá trình lọc ANOVA; (ii) áp dụng bộ lọc rừng ngẫu nhiên trên kết quả ANOVA; và (iii) áp dụng bộ lọc dựa trên các nhóm biến cụm sau khi lọc ANOVA. Mỗi chiến lược trong ba chiến lược này sẽ được kết hợp với các công cụ phân loại khác nhau. Hàm sau đây triển khai phương pháp tiếp cận liên quan đến việc tạo một nhóm mô hình, mỗi mô hình được áp dụng cho một tập hợp các biến dự báo khác nhau. 
Hàm này sẽ được gọi từ bên trong hàm triển khai quy trình làm việc của chúng  tôi (giải pháp cho nhiệm vụ dự đoán) mà chúng tôi sẽ trình bày sau.

> varsEnsemble <- function(tgt, train, test,
+                          fs.neth,
+                          baseLearner, blPars,
+                          predictor, predPars,
+                           verb-FALSE)
+ {
+        require (Hnise, quietly=TRUE)
+        v <- varclus (as.matrix(train [,-which(colnames(train) ==tgt)]))
+        varsSets <-lapply(1:fs.meth[[3]], function(x)
+                 getVarsSet (v$hclust,nvars-fs.neth[[2]]))
+        preds <- matrix (NA,ncol-length (varsSets), nrow=NROW(test)) 
+        for(v in seq(along-varsSets)) {


+        if (baseLearner--'knn')
+            preda [v]<do.call("MN",
+                              c(list(as.formula (paste(tgt,
+                                              paste(varsSets [[v]],
+                                                     collapse='+'),
+                                                 sep11)),
+                                     train[,c(tgt,varsSets [[v]])].
+                                    test [,c(tgt, varsSets[[v]])]),
+                                blPars)
                              )
+       else {
+          m <do.call(baseLearner,
+                     c(list(as.formula(paste(tgt,
+                                             paste(varsSets [[v]],
+                                                    collapse='+'),
+                                             sep='-')),
+                          train [,c(tgt, varsSets [[v]])]),
+                     blPars)
+                   )
+          preds [,v] <-do.call(predictor,
+                               c(list(m, test [,c(tgt, varsSets[[v]])]), 
+                                 predPars))
+       }
+    }

+   ps <- apply(preds,1,function(x)
+         levels (factor(x)) [which.max(table(factor(x)))]) 
+   factor(ps,
+          levels-1:nlevels (train [, tgt]), 
+          labels=levels (train [, tgt]))
+ }
Các đối số đầu tiên của hàm này là tên của biến mục tiêu, tập huấn luyện và tập kiểm tra. Đối số tiếp theo (fs.meth) là danh sách chứa các tập tên biến (các cụm thu được) mà từ đó chúng ta nên lấy mẫu một biến để tạo ra các biến dự đoán của từng thành viên trong nhóm. Sau đó, chúng ta có hai đối số (baseLearner và blPare) 
cung cấp tên của hàm triển khai trình học được sử dụng trên từng thành viên trong nhóm và danh sách tương ứng của các tham số học. Cuối cùng, chúng ta có tên của hàm được sử dụng để thu được các dự đoán của mô hình và các tham số của nó. Kết quả của hàm là tập các dự đoán của nhóm đối với tập kiểm tra đã cho. 
Các dự đoán này thu được bằng cơ chế bỏ phiếu giữa các thành viên trong nhóm. Sự khác biệt giữa các thành viên trong nhóm chỉ nằm ở các biến dự đoán được sử dụng, được xác định bởi các tham số fa.meth. Các tập này là kết quả của quá trình phân cụm biến, như đã đề cập trong Phần 7.3.4.
Với sự tương đồng của các nhiệm vụ được thực hiện bởi mỗi thuật toán phân loại, chúng tôi đã tạo ra một hàm quy trình công việc do người dùng xác định duy nhất sẽ nhận một trong các tham số là người học sẽ được sử dụng. Hàm ALLb.wf() mà chúng tôi trình bày bên dưới thực hiện ý tưởng này:

> ALLb.uf <- function (form, train, test,
+
learner, learner.pars-NULL,
predictor="predict", predictor.pars=NULL, featSel.neth="82",
available.faMethods=list(s1=list("all"), 82=list('rf',30),))


+                                                    3-list('varclus',30,50)),
+                    .model=FALSE,
+                    ...)
+ (
+       ## The characteristics of the selected feature selection method
+       fs.meth <- available.fsMethods [[featSel.neth]]

+       ## The target variable
+       tgt <- as.character (forn [[2]])
+       tgtCol <- which(colnames (train)==tgt)

+       ## Anova filtering
+       <- Anova (train [, tgt], p=0.01)
+       ff <- filterfun(f)
+       genes <- genefilter(t(train [,-tgtCol]),ff)
+       genes <- names (genes) [genes]
+       train <- train [,c(tgt, genes)]
+       test <- test [,c(tgt,genes)] 
+       tgtCol <- 1

+       ## Specific filtering
+       if (fs.neth[[1]]=='varclus') {
+           pred <- varsEnsemble (tgt, train, test, fs.neth,
+                                  learner, learner.pars,
+                                  predictor, predictor.pars, 
+                                  list(...))
+      } else {
+        if (fa.neth[[1]]=='') {
+          require(randonForest, quietly=TRUE)
+          rf <- randomForest (form, train, importance=TRUE)
+          imp <- importance(rf)
+          rf.genes<- rownanes (imp) [order(inp[, "MeanDecreaseAccuracy"],
+                               decresing = TRUE) (1:fs.meth[2])]
+          train <- train [,c(tgt,rf.genea)]
+          test<- test [,c(tgt,rf.genes)]
+        }
+        )
+          if (learner- 'knn') (
+        pred <- KNN (form, train, test,
+                     stand.stants=list(rowMedians(t(as.matrix(train[,tgtCol])))),
+                          rowIQRs(t(as.matrix(train[,tgtCol])))),
+                          ...)
+         else {
+            model <- do.call(learner.c(list(form,train),learner.para))
+            pred <- do.call(predictor,c(list(model,test),predictor.para)) 
+         }

+      }

+    return(list(trues-responseValues (form, test), preds-pred,
+                model-if (model && learner!="knn") model else NULL)) 
+ }

Luồng công việc do người dùng xác định này sẽ được gọi từ bên trong gói performanceEs-timation bootstrap routines cho mỗi lần lặp lại của quy trình. Hàm luồng công việc chấp nhận công thức, bộ huấn luyện và bộ kiểm tra làm ba đối số đầu tiên, là bắt buộc đối với bất kỳ hàm luồng công việc nào trong bối cảnh cơ sở hạ tầng do gói performanceEstimation cung cấp. Sau đó, 
chúng ta có các tham số chỉ định giai đoạn học và dự đoán. Cuối cùng, chúng ta có các tham số featSel.meth và available.fsMethods cho phép người dùng chọn một phương pháp chọn tính năng từ bên trong một tập hợp các phương án thay thế. Theo mặc định, các phương án thay thế này là: (i) "s1" biểu thị việc sử dụng tất cả các tính năng thu được sau khi lọc ANOVA: (ii) "82" liên quan đến việc sử dụng 
rừng ngẫu nhiên để chọn 30 tính năng hàng đầu theo mức giảm độ chính xác trung bình; và (iii) "s3" để sử dụng phương pháp cụm cụm biến dựa trên 50 mô hình, mỗi mô hình được xây dựng bằng 30 bộ dự báo được chọn ngẫu nhiên từ 30 cụm tính năng gốc. Ngoài ba phương án thay thế này về mặt lọc tính năng, chúng tôi cũng sẽ xem xét một số biến thể tham số cho mỗi thuật toán phân loại mà chúng tôi sẽ thử. 
Danh sách sau đây chứa tất cả các biến thể cần được xem xét trong các thí nghiệm ước tính của chúng tôi:

> vars <- list()
> vars$randonForest <- list (learner.pars-list (ntree-c (500,750,1000),
+                                               ntry=c(5,15)),
+                            preditor.pars=list(type="response"))
> vars$avm <- list (learner.pars-list (cost-c(1,100),
+                                     ganna=c(0.01, 0.001,0.0001)))
> vars knn <- list (learner.pars=list(k=c(3,5,7),
+                                     stand-c(TRUE, FALSE)))
> vars$featureSel <- list (feat Sel.neth=c("a1", "a2", "a3"))

Điều này có nghĩa là chúng ta sẽ so sánh 6 (3×2) biến thể tham số của rừng ngẫu nhiên kết hợp với 3 phương pháp lựa chọn tính năng thay thế (do đó tổng cộng có 18 biến thể sử dụng rừng ngẫu nhiên làm bộ phân loại), cộng với 18 biến thể khác dựa trên SVM và 18 biến thể dựa trên bộ phân loại k-nearest neighbor. Mỗi trong số 54 phương án thay thế này sẽ có độ chính xác phân loại được ước tính thông qua 100 lần lặp lại 
của một thử nghiệm bootstrap. Quá trình ước tính này sẽ mất nhiều thời gian để tính toán. Trong bối cảnh này, chúng tôi không khuyên bạn chạy các thử nghiệm sau trừ khi bạn biết về ràng buộc thời gian này. Các đối tượng thu được từ thử nghiệm này có sẵn trên trang web của cuốn sách để bạn có thể tiến hành phần còn lại của quá trình phân tích mà không cần phải chạy tất cả các thử nghiệm này. 
Mã để chạy toàn bộ các thử nghiệm như sau:

> library(performanceEstimation)
> library(class)
> library(randonForest)
> library(1071)
> library(genefilter)
> load('myALL. Rdata') #loading the previously saved object with the data
>

> dt <- data.frame(t(exprs (ALLb)), Mut-ALLb$mol.bio)
>
> set.seed(1234)
> # The learners to evaluate
> TODO <- c('knn', 'avm', 'randonForest')
> for(td in TODO) {
+     assign(td,
+         performanceEstimation(
+            PredTask(Mut - .,dt,'ALL'),
+            do.call('workflowVariants',
+                    c(list('ALLb.wf', learner td, varsRootName=td),
+                      vars [[td]],
+                      vars$featureSel
+                       )
+                     )
+            EstimationTask(metrics="acc", method-Bootstrap (nReps=100)),
+            cluster-TRUE
       )
       )
+   save(list=td, file-paste(td, 'Rdata',sep='.'))
+  }

Mã bắt đầu bằng cách áp dụng bộ lọc đơn giản loại bỏ các đầu dò điều khiển và các gen có độ biến thiên rất nhỏ. Các gen còn lại tạo thành tập dữ liệu được sử dụng để chạy các thí nghiệm bootstrap ước tính độ chính xác của các quy trình công việc khác nhau mà chúng ta đang xem xét cho nhiệm vụ dự đoán loại đột biến. Phần chính của mã bao gồm một vòng lặp đi qua ba thuật toán phân loại. 
Điều này có nghĩa là chúng ta chạy riêng các biến thể của từng phương pháp này. Với số lượng lớn các biến thể và thực tế là chúng ta đang sử dụng 100 lần lặp lại của một thí nghiệm bootstrap cho mỗi biến thể, mã này mất một thời gian để chạy. Trong bối cảnh này, chúng ta đã sử dụng cài đặt tham số cluster-TRUE trong đối số thứ tư của hàm performance Estimation(). 
Điều này sẽ sử dụng tất cả trừ một lõi của máy tính nơi các thí nghiệm đang được thực hiện, với mỗi lõi chạy một trong các lần lặp song song. Tùy thuộc vào số lượng lõi của máy, điều này sẽ dẫn đến tốc độ tăng đáng kể. Vào cuối mỗi lần lặp, kết quả của thuật toán phân loại tương ứng sẽ được lưu trong một tệp. Các tệp này có sẵn trên trang web của cuốn sách để bạn có thể tránh chạy tất cả 
các thử nghiệm và vẫn có thể phân tích kết quả của chúng bằng cách tải xuống các tệp từ trang web. Giả sử chúng được lưu trong thư mục làm việc hiện tại của phiên R của bạn, bạn có thể tải nội dung của các tệp như sau:

> ## tải kết quả của các phép tính
> load("knn. Rdata")
> load("svm. Rdata")
> load("randonForest.Rdata")

Kết quả của tất cả các biến thể của một học viên được chứa trong một đối tượng ComparisonResults riêng biệt. Ví dụ, nếu bạn muốn xem biến thể SVM nào là tốt nhất, bạn có thể đưa ra:

> rankWorkflows (svm, maxs = TRUE)
$ALL
$ALLSace  
   Workflow   Estimate
1    svm.v8  0.8126319
2   svm.v12  0.8112365
3    svm.v10 0.8064391
4     avm.v6 0.8046412
5     svm.v7 0.7978988

Hàm rankworkflows () lấy một đối tượng thuộc lớp ComparisonResults và thu được các biến thể có hiệu suất tốt nhất cho mỗi số liệu thống kê được ước tính trong quá trình thử nghiệm. Theo mặc định, hàm này giả định rằng "tốt nhất" có nghĩa là các giá trị nhỏ hơn. Trong trường hợp số liệu thống kê cần được tối đa hóa, như độ chính xác, chúng ta có thể sử dụng tham số maxs như đã làm ở trên.4
Để có góc nhìn tổng thể về tất cả các quy trình công việc đã thử, chúng ta có thể kết hợp ba đối tượng:

> all. trials <- mergeEstimationRes (svm, knn, randonForest, by ="workflows")

Với đối tượng Kết quả so sánh, chúng ta có thể kiểm tra điểm tổng thể tốt nhất của các lần thử nghiệm:

> rankWorkflows (all. trials, top-10, maxs = TRUE)
$ALL
$ALL$acc
    Workflow   Estimate
1    8vm.v8    0.8126319
2    svm.v12   0.8112365
3    knn.v7    0.8084350
4    knn.v8    0.8084350
5    knn.v9    0.8084350
6    knn.v10   0.8084350
7    knn.v11   0.8084350
8    knn.v12   0.8084350
9    svm.v10   0.8064391
10   avm.v6    0.8046412

Đáng ngạc nhiên là không có biến thể rừng ngẫu nhiên nào xuất hiện trong 10 giải pháp hàng đầu. Điểm số cao nhất thu được bằng một biến thể của phương pháp SVM. Chúng ta hãy kiểm tra các đặc điểm của nó:

> getWorkflow("svm.v8", all. trials)

Workflow Object:
Workflow ID      :: svn.v8
Workflow Function:: ALLb.wf 
     Parameter values:
learner.pars -> cost-100 gamma-0.01
learner -> avm
featSel.neth -> 2

Biến thể này sử dụng 30 gen được lọc theo rừng ngẫu nhiên (chiến lược "s2") và sử dụng SVM với các thiết lập tham số là 100 cho chi phí và 0,01 cho gamma. Cũng thú vị khi quan sát thấy trong số 10 điểm cao nhất, chỉ có điểm cuối cùng ("svm.v6") không sử dụng 30 gen được lọc theo rừng ngẫu nhiên. Làm thế nào để có được thông tin đó theo chương trình mà không phải chạy thủ công hàm getWorkflow() 
ở trên trên tất cả 10 quy trình công việc? Mã sau đây cho bạn biết cách thực hiện điều này:
*Trong trường hợp chúng ta đo một số thống kê, một số sẽ được giảm thiểu và một số khác được tối đa hóa, tham số naxs chấp nhận một vectơ các giá trị Boolean, nhiều như số thống kê trong tác vụ ước tính.

# Không thể xuất hình ảnh lên file. (Kết quả ước tính hiệu suất Bootstrap)

> top10WFnames <- rankWorkflows (all.trials, top-10,
+                                maxs = TRUE) [["ALL"]] [["acc"]] [, "Workflow"]
> sapply(top10WFnames, function (WFid) getWorkflow (WFid, all. trials) @pars$featSel.neth)

svm.v8 svm.v12 knn.v7 knn.v8 knn.v9 knn.v10 knn.v11 knn.v12 svn.v10 
 "82"   "82"    "82"   "82"   "82"   "82"    "82"    "82"     "82"

 Đầu tiên, chúng ta sử dụng đầu ra của hàm rankWorkflows() để lấy tên của 10 quy trình công việc hàng đầu. Đối với mỗi tên này, chúng ta áp dụng hàm getWorkflow() để lấy đối tượng quy trình công việc tương ứng, từ đó chúng ta trích xuất khe chứa các tham số học viên (các phần khe của các đối tượng này), là một danh sách, nơi cuối cùng chúng ta lấy được giá trị của tham số featSel.meth. 
Như bạn có thể thấy, chỉ có quy trình công việc cuối cùng sử dụng phương pháp chọn tính năng "s1", tức là sử dụng tất cả các gen thu được từ quá trình lọc đơn giản.
Hình 7.5 hiển thị kết quả của 10 quy trình công việc hàng đầu này trên 100 lần lặp của quy trình ước tính bootstrap. Hình được lấy bằng,

> plot (subset(all. trials, workflows=top10WFnames))

Chúng ta có thể thấy rằng kết quả của các quy trình công việc khác nhau có vẻ rất giống nhau. Chúng ta có thể có được câu trả lời chính thức hơn cho câu hỏi liệu điểm của quy trình công việc chiến thắng có tốt hơn đáng kể so với điểm của các quy trình công việc khác trong top 10 hay không như sau:

>ps <- pairedComparisons (subset(all.trials, workflows-top10WFnanes), baseline="svn.v8") 
> pasacc$WilcoxonSignedRank.test


, , ALL

            MedScore   DiffMedScores    p.value
svm.v8     0.8235294              NA         NA
svm.v12    0.8235294     0.000000000   0.7000463
knn.v7     0.8169856     0.006543766   0.7941389
knn.v8     0.8169856     0.006543766   0.7941389
knn.v9     0.8169856     0.006543766   0.7941389
knn.v10    0.8169856     0.006543766   0.7941389
knn.v11    0.8169856     0.006543766   0.7941389
knn.v12    0.8169856     0.006543766   0.7941389
svm.v10    0.8086312     0.014898200   0.2240278
svm.v6     0.8055556     0.017973856   0.4055620

Như bạn thấy, không có sự khác biệt đáng kể về mặt thống kê giữa 10 quy trình công việc này. Chúng tôi đã sử dụng kiểm định thứ hạng có dấu Wilcoxon cho mục đích này, vì thí nghiệm này chỉ bao gồm một nhiệm vụ dự đoán duy nhất. Kiểm định này cho phép chúng tôi thực hiện các so sánh theo cặp giữa các quy trình công việc khác nhau và người đạt điểm cao nhất.
Đôi khi chúng tôi quan tâm đến việc kiểm tra hành vi của một quy trình công việc nhất định trên một lần lặp cụ thể của các thí nghiệm ước tính này (có thể vì điểm của quy trình công việc tại lần lặp đó là bất thường). Ví dụ, chúng tôi có thể thử lấy ma trận nhầm lẫn của một số quy trình công việc trên một lần lặp. Để lấy ma trận nhầm lẫn (xem trang 142), 
chúng tôi cần biết dự đoán thực tế của các mô hình là gì. Hàm quy trình công việc do người dùng xác định (ALLb.wf) của chúng tôi trả về thông tin này. Chúng tôi có thể kiểm tra nhãn lớp đúng và được dự đoán cho bất kỳ lần lặp nào của phương pháp bootstrap và lấy ma trận nhầm lẫn tương ứng với thông tin này. Mã sau đây cung cấp minh họa cho một lần lặp cụ thể:

> iteration <- 1 # any number between 1 and 100 in this case
> itInfo <- getIterations Info (all. trials, workflow="svn.v8",it-iteration) 
> table(itInfo$trues, itInfo$preds)


            ALL1/AF4 BCR/ABL E2A/PBX1 NEG
ALL1/AF4       3        0       0      0
BCR/ABL        0        12      0      3
E2A/PBX1       0        0       0      1
NEG            0        1       1      14

Trong ví dụ này, chúng ta có thể quan sát thấy mô hình dự đoán đúng tất cả các trường hợp có đột biến ALL1/AF4. Hơn nữa, chúng ta cũng có thể quan sát thấy rằng hầu hết các lỗi của mô hình bao gồm dự đoán lớp NEG cho một trường hợp có một số đột biến, tức là âm tính giả, điều này không thực sự thú vị trong phạm vi ứng dụng này. Tuy nhiên, 
điều ngược lại cũng xảy ra với hai mẫu không có đột biến, được dự đoán không chính xác là có một số bất thường. Chúng ta nên lưu ý rằng hàm getIterations Info() có thể được sử dụng để lấy bất kỳ thành phần nào của danh sách do một trong các quy trình công việc liên quan đến thí nghiệm trả về. Đặc biệt, đối với các quy trình công việc do người dùng xác định,
người dùng là người quyết định giá trị trả về của các hàm quy trình công việc, điều này có nghĩa là bạn có thể đưa bất kỳ thông tin nào bạn cho là hữu ích vào danh sách thu được từ việc chạy quy trình công việc.

7.5 Tóm tắt
Mục tiêu chính của chương này là giới thiệu cho người đọc một loạt các ứng dụng quan trọng của khai thác dữ liệu nhận được nhiều sự chú ý từ cộng đồng R: tin sinh học. Trong bối cảnh này, chúng tôi đã khám phá một số công cụ của dự án Bioconductor, cung cấp một bộ lớn các gói R chuyên biệt cho loại ứng dụng này. Là một ví dụ cụ thể, chúng tôi đã giải quyết một nhiệm vụ dự đoán tin sinh học: dự báo loại đột biến gen liên quan đến các mẫu bệnh nhân mắc bệnh bạch cầu lymphoblastic cấp tính tế bào B. Một số mô hình phân loại đã được thu thập dựa trên thông tin liên quan đến mức độ biểu hiện trên một tập hợp gen thu được từ các thí nghiệm mảng vi mô. Về các khái niệm khai thác dữ liệu, chương này tập trung vào các chủ đề chính sau:
• Các phương pháp lựa chọn tính năng cho các vấn đề có số lượng lớn các yếu tố dự báo
⚫ Các phương pháp phân loại
⚫ Rừng ngẫu nhiên
• K-Nearest neighbors
. SVM
• Các tập hợp sử dụng các tập con khác nhau của các biến dự báo
⚫ Các thí nghiệm Bootstrap
Liên quan đến R, chúng ta đã học được một số kỹ thuật mới, cụ thể là,
⚫ Cách xử lý dữ liệu mảng vi mô
⚫ Sử dụng các thử nghiệm ANOVA để so sánh các giá trị trung bình giữa các nhóm dữ liệu
⚫ Phân cụm các biến của một vấn đề
• Thu thập các tập hợp với các mô hình đã học bằng cách sử dụng các biến dự báo khác nhau
• Thu thập các mô hình k-gần nhất
Ước tính độ chính xác của các mô hình bằng cách sử dụng bootstrap.

              












 



