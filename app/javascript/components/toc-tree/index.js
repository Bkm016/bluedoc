import React, { Component } from 'react';
import { graph } from 'bluedoc/graphql';
import Tree from './tree';
import {
  getTreeFromFlatData,
} from './utils';


const getTocList = graph(`
  query (@autodeclare) {
    repositoryTocs(repositoryId: $repositoryId) {
      id,
      docId,
      title,
      url,
      parentId,
      depth
    }
  }
`);

const moveTocList = graph(`
  mutation (@autodeclare) {
    moveToc(id: $id, targetId: $targetId, position: $position )
  }
`);

class TocTree extends Component {
  state = {
    treeData: [],
    loading: true,
  }

  componentDidMount() {
    this.getTocList();
  }

  // fetch Toc List
  getTocList = () => {
    const { repositoryId } = this.props;
    getTocList({ repositoryId }).then((result) => {
      this.setState({
        treeData: getTreeFromFlatData({ flatData: result.repositoryTocs, rootKey: null }),
        loading: false,
      });
    }).catch((errors) => {
      App.alert(errors);
    });
  }

  onMoveNode = (data) => {
    const {
      node, nextPath, treeData,
    } = data;

    const len = nextPath.length;
    const params = {
      id: node.id,
      position: 'right',
      targetId: null,
    };
      // 插在之前
    if (len === 1 && nextPath[0] === 0) {
      params.position = 'left';
      params.targetId = treeData[1].id;
      // 插入子集
    } else if (len > 1 && (nextPath[len - 1] - nextPath[len - 2] === 1)) {
      const targetPath = nextPath.slice(0, len - 1);
      params.position = 'child';
      params.targetId = this.getNodeByPath({ treeData, path: targetPath }).id;
      // 插在之后
    } else {
      const targetPath = [...nextPath];
      targetPath[len - 1] -= 1;
      params.targetId = this.getNodeByPath({ treeData, path: targetPath }).id;
    }
    moveTocList(params).then((result) => {
      console.log(result, params, '保存成功');
    });
  }

  onChange = treeData => this.setState({ items: treeData })

  render() {
    const { treeData } = this.state;
    return (
      <Tree
        treeData={treeData}
        onChange={this.onChange}
        onMoveNode={this.onMoveNode}
      />
    );
  }
}

export default TocTree;
