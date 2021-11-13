import os


def find_clean_directory(directory=".", max_size=(1024*1024*150), skip_directories=[]):
    """用于查找可以被 rclone 安全同步（绝对不包含大于 max_size 的文件）的目录的函数。
    """
    # 支持非完整路径
    for i in range(0, len(skip_directories)):
        skip_directories[i] = os.path.join(directory, skip_directories[i])

    # 未污染目录列表
    clean_directories = []

    def walk(node):
        """未被污染会返回 True，反之返回 False。
        """
        assert os.path.isdir(node)

        is_clean = True
        clean_nodes = []
        for i in os.listdir(node):
            node_i = os.path.join(node, i)

            if os.path.isdir(node_i):
                if node_i in skip_directories:
                    # skip_directories 必须被视作已污染
                    is_clean = False

                    continue

                if walk(node_i) is True:
                    # 暂存未污染的子节点
                    clean_nodes.append(node_i)
                else:
                    is_clean = False
            else:
                size = os.stat(node_i).st_size

                # 含有大于 max_size 的文件即视为被污染
                if size > max_size:
                    is_clean = False

        if is_clean:
            # 未被污染时直接抛弃子节点（合并）
            pass
        else:
            # 被污染后立即提交未污染的子节点
            clean_directories.extend(clean_nodes)

        return is_clean

    if walk(directory) is True:
        # 整个目录都未污染
        clean_directories.append(directory)

    return clean_directories


for i in find_clean_directory(os.path.expanduser("~/my-msod"), skip_directories=["encrypted"]):
    print(i)
