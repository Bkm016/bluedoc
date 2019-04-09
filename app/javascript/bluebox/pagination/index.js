import ReactPaginate from 'react-paginate';

export default class Pagination extends React.Component {
  onPage = (selectedItem) => {
    const newPage = selectedItem.selected + 1;
    console.log('goto page', newPage);

    this.props.onPage(newPage);
  }

  render() {
    const { pageInfo = {} } = this.props;

    if (pageInfo.totalCount === 0 || pageInfo.totalPages === 1) {
      return <div />;
    }

    return <ReactPaginate
      pageCount={pageInfo.totalPages}
      pageRangeDisplayed={3}
      onPageChange={this.onPage}
      breakClassName="gap"
      activeLinkClassName="selected"
      previousLinkClassName="previous_page"
      nextLinkClassName="next_page"
      pageLinkClassName="page-number"
      disabledClassName="disabled"
      containerClassName="pagination"
    />;
  }
}
