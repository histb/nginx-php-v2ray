<?php
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // 执行脚本
    exec('rm _h5ai.footer.md');
    exec('rm _h5ai.upload.php');
    exec('rm 使用说明.txt');

    // 返回并刷新到上一页
    header('Location: /');
    exit();
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>运行脚本</title>
    <style>
        body {
            display: flex;
            justify-content: center;
            align-items: center;
            height: 20vh;
        }
    </style>
</head>
<body>
	<h3>部署后一次性清除敏感文档和上传功能</h3>
	<p>&nbsp;</p>
	<p><br/>
</p>
	<form method="post" action="">
      <button type="submit">点击关闭上传功能</button>
    </form>
</body>
</html>